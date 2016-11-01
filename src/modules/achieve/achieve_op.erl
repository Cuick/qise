%% Author: MacX
%% Created: 2010-12-10
%% Description: TODO: Add description to achieve_op
-module(achieve_op).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([load_achieve_role_from_db/1,export_for_copy/0,write_to_db/0,load_by_copy/1,
		 achieve_reward/2,achieve_open/0,achieve_update/2,achieve_update/3,achieve_init/0,
		 achieve_bonus/2,has_items_in_bonus/1,hook_on_swap_equipment/4,hook_on_swap_pet_equipment/1,
		 chess_spirit_team/1,role_attr_update/0
		 ]).
-include("mnesia_table_def.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("error_msg.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
-include("base_define.hrl").
%%
%% API Functions
%%
init()->
	put(achieve_role,[]),
	put(achieve,[]).

load_achieve_role_from_db(RoleId)->
	case achieve_db:get_achieve_role(RoleId) of
		{ok,[]}->
			init();
		{ok,RoleAchievesDB}->
			[{achieve_role,MyRoleId,RoleAchieve}] = RoleAchievesDB,
			{Open,RoleTargets} = RoleAchieve,
			{_,Chapter,_} = Open,
			case achieve_db:get_achieve_by_chapter(Chapter) of
				[]->
					AchieveParts=[],
					put(achieve_role,{MyRoleId,RoleAchieve});
				AchievePartsDB->
					AchieveParts=AchievePartsDB,
					RefreshRoleTargets = lists:foldl(fun(AchievePart,Acc)->
							{AchieveId,_,_,_,_,_,_,_}=AchievePart,
							case lists:keyfind(AchieveId, 1, RoleTargets) of
								false->
									Acc ++ [{AchieveId,0,0}];
								Tuple->
									Acc ++ [Tuple]
							end
						end,[], AchievePartsDB),
					put(achieve_role,{MyRoleId,{Open,RefreshRoleTargets}}),
					if 
						erlang:length(RefreshRoleTargets) > erlang:length(RoleTargets)->
						   	AchieveRoleUpdate={MyRoleId,{Open,RefreshRoleTargets}},
							achieve_db:async_update_achieve_role_to_mnesia(MyRoleId,AchieveRoleUpdate);
						true->
							nothing
					end
			end,
			put(achieve,AchieveParts);
		_->
			init()
	end.

check_part_is_finished(AchieveId,Target,Script)->
	case Script of
		[]->
			{other};
		Value->
			exec_beam(Value,todo,AchieveId,Target)
	end.
	
open_next_chapter(Chapter)->
	case get(achieve_role) of
		[]->
			nothing;
		AchieveRole->
			{MyRoleId,{{S,C,_},_}} = AchieveRole,
			if 
				Chapter=:=C,S=:=1->
					case achieve_db:get_achieve_by_chapter(Chapter+1) of
						[]->
							nothing;							
						AchievePartsDB->
							put(achieve,AchievePartsDB),
							Open={0,Chapter+1,0},
							send_achieve_update({0,Chapter+1,0,0,0}),
							AchieveFun = fun({AchieveId,_,_,Target,_,_,_,Script},Acc)->
										 {CC,PP} = AchieveId,
										 case Script of
											 []->
												 Acc ++ [{AchieveId,0,0}];
											 Value->
												 [{_,_,Sum}] = Target,
												 case check_part_is_finished(AchieveId,Target,Value) of
													 {true,Count}->
														 put(achieve,lists:keydelete(AchieveId, 1,get(achieve))),
														 send_achieve_update({2,CC,PP,0,0}),
														 Acc ++ [{AchieveId,Count,2}];
													 {false,Count}->
														 send_achieve_update({0,CC,PP,Count,Sum}),
														 Acc ++ [{AchieveId,Count,0}];
													 _->
														 Acc ++ [{AchieveId,0,0}]
												 end
										 end
										 end,
							CurTargets = lists:foldl(AchieveFun, [], AchievePartsDB),
							Achieves = {MyRoleId,{Open,CurTargets}},
							achieve_db:sync_update_achieve_role_to_mnesia(MyRoleId,Achieves),
							put(achieve_role,Achieves)
							
					end;
				true->
					nothing
			end
	end.

export_for_copy()->
	{get(achieve_role),get(achieve)}.
	
write_to_db()->
	nothing.

load_by_copy({RoleAchieves,Achieve})->
	put(achieve_role,RoleAchieves),
	put(achieve,Achieve).

has_items_in_bonus(Bonus)->
	Items_count = lists:foldl(fun({Class,_Count},Acc)->
								if 
									Class>3->
										Acc ++ [Class];
									true->
										Acc
								end
								end,[],Bonus),
	case erlang:length(Items_count) =:= 0 of
		true ->
			0;
		false->
			erlang:length(Items_count)
	end.

achieve_bonus(Bonus,Reason)->
	BonusFun=fun({Class,Count})->
				case Class of
					 1->%%exp
						 role_op:obtain_exp(Count);
					 2->%%silver
						 role_op:money_change(?MONEY_BOUND_SILVER, Count, Reason);
					 3->%%ticket
						 role_op:money_change(?MONEY_TICKET, Count, Reason);
					 TemplateId->%%items
						 case package_op:can_added_to_package_template_list([{Class,Count}]) of
							false->
								Message = achieve_packet:encode_achieve_error_s2c(?ERROR_PACKEGE_FULL),
								role_op:send_data_to_gate(Message);
							_->	
						 		role_op:auto_create_and_put(TemplateId, Count, Reason)
						 end
				end
			 end,
	lists:foreach(BonusFun, Bonus).

check_chapter_finished()->
	case get(achieve) of
		[]->
			nothing;
		AchieveParts->
			if erlang:length(AchieveParts) =:= 1->
				case get(achieve_role) of
					[]->
						nothing;
					AchieveRole->
						{MyRoleId,{{_,Chapter,ChapterPart},ChapterTargets}} = AchieveRole,
						{_,_,_,Target,_,_,_,_}=lists:keyfind({Chapter,0}, 1, AchieveParts),
						CheckChapterFun = fun({AchieveId,_Target,Status},Acc)->
							case Status of 
								1->
									Acc ++ [AchieveId];
								_->
									Acc
							end
						 end,
						FinishAchieves = lists:foldl(CheckChapterFun, [], ChapterTargets),
						SortedFinished = lists:sort(FinishAchieves),
						if SortedFinished =:= Target->
							AchieveRoleUpdate={MyRoleId,{{2,Chapter,ChapterPart},lists:keyreplace({Chapter,ChapterPart}, 1, ChapterTargets, {{Chapter,ChapterPart},0,2})}},
							achieve_db:sync_update_achieve_role_to_mnesia(MyRoleId,AchieveRoleUpdate),
							put(achieve_role,AchieveRoleUpdate),
							send_achieve_update({2,Chapter,ChapterPart,0,0});
						   true->
							   nothing
						end
				end;
			   true->
				   nothing
   			end
	end.

achieve_reward(Chapter,Part)->
	case get(achieve_role) of
		[]->
			Errno=?ERROR_ACHIEVE_NOT_OPENED;
		{MyRoleId,{ChapterTag,ChapterTargets}}->
			case lists:keyfind({Chapter,Part}, 1, ChapterTargets) of
				false->
					Errno=?ERROR_ACHIEVE_TARGET_NOEXSIT;
				ChapterTargetTuple->
					{_,Finished,Status}=ChapterTargetTuple,
					if 
						Status=:=2->
							case achieve_db:get_achieve_info({Chapter,Part}) of
								[]->
									Errno=?ERRNO_NPC_EXCEPTION;
								AchieveInfo->
									Errno = [],
									Bonus = achieve_db:get_bonus(AchieveInfo),
									achieve_bonus(Bonus,achieve_bonus),
									{_,CC,PP} = ChapterTag,  
									if Part > 0->
											AchieveRoleUpdate={MyRoleId,{ChapterTag,lists:keyreplace({Chapter,Part}, 1, ChapterTargets, {{Chapter,Part},Finished,1})}},
											achieve_db:sync_update_achieve_role_to_mnesia(MyRoleId,AchieveRoleUpdate),
											put(achieve_role,AchieveRoleUpdate),
											send_achieve_update({1,Chapter,Part,0,0}),
											check_chapter_finished();
										 Part =:= 0->
											AchieveRoleUpdate={MyRoleId,{{1,CC,PP},lists:keyreplace({Chapter,Part}, 1, ChapterTargets, {{Chapter,Part},Finished,1})}},
											achieve_db:sync_update_achieve_role_to_mnesia(MyRoleId,AchieveRoleUpdate),
											put(achieve_role,AchieveRoleUpdate),
											send_achieve_update({1,Chapter,Part,0,0}),
											open_next_chapter(Chapter);
										true->
											nothing
										end
							end;
						true->
							Errno=?ERROR_ACHIEVE_TARGET_NOT_FINISHED
					end
			end
	end,
	if 
		Errno =/= []->
			Message_failed = achieve_packet:encode_achieve_error_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.			

achieve_open()->
	case get(achieve_role) of
		[]->
			MyRoleId = get(roleid),
			Open = {0,1,0},
			case achieve_db:get_achieve_by_chapter(1) of
				[]->
					Errno = ?ERRNO_NPC_EXCEPTION;
				AchievePartsDB->
					put(achieve,AchievePartsDB),
					AchieveFun = fun({AchieveId,_,_,Target,_,_,_,Script},Acc)->
										 case Script of
											 []->
												 Acc ++ [{AchieveId,0,0}];
											 Value->
												 case check_part_is_finished(AchieveId,Target,Value) of
													 {true,Count}->
													 	Acc ++ [{AchieveId,Count,2}];
													 {false,Count}->
														 Acc ++ [{AchieveId,Count,0}];
													 _->
														 Acc ++ [{AchieveId,0,0}]
												 end
										 end
						 end,
					CurTargets = lists:foldl(AchieveFun, [], AchievePartsDB),
					Achieves = {MyRoleId,{Open,CurTargets}},
					achieve_db:sync_update_achieve_role_to_mnesia(MyRoleId,Achieves),
					put(achieve_role,Achieves),
					achieve_init(),
					Errno=[]
			end;
		_OriAchieve->
			Errno = ?ERROR_ACHIEVE_OPENED
	end,
	if 
		Errno =/= []->
			Message_failed = achieve_packet:encode_achieve_error_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

achieve_update(Message,Match)->
%%  	achieve_update(Message,Match,1),
	goals_op:goals_update(Message,Match).

achieve_update(Message,Match,MsgValue)->
	goals_op:goals_update(Message,Match,MsgValue).
%% 	case get(achieve) of 
%% 		[]->
%% 			nothing;
%% 		AchieveParts->
%% 			lists:foreach(fun(Achieve)->
%% 						  {{C,P},_,_,Target,_,_,Type,Script} = Achieve,
%% 						  if P =/= 0 ->
%% 						  	[{Msg,TargetMatch,Count}] = Target,
%% 						  	if 
%% 							  Message =:= {Msg}->
%% 								  MatchLength = case erlang:length(Match) of
%% 													1 ->
%% 														[M] = Match,
%% 														1;
%% 													Len->
%% 														M = 0,
%% 														Len
%% 												end,
%% 								  case Type of 
%% 									  count->
%% 										  MatchResult = lists:member(M, TargetMatch),
%% 										  if TargetMatch=:=[0];MatchResult->
%% 										  		count_function({C,P},Match,Count,MsgValue);
%% 											 true->
%% 												 nothing
%% 										  end;
%% 									  match->
%% 										  MatchResult = lists:member(M, TargetMatch),
%% 										  if 
%% 											  MatchResult->
%% 												  match_function({C,P},Match,Target,Count,MsgValue,Script);
%% 											  MatchLength>1->
%% 												  match_function({C,P},Match,Target,Count,MsgValue,Script);
%% 											  true->
%% 												 nothing
%% 										  end;
%% 									  matchnum->
%% 										  if TargetMatch=:=[0];TargetMatch=:=Match->
%% 										  		matchnum_function({C,P},Match,Count,MsgValue);
%% 											 true->
%% 												nothing
%% 										  end;
%% 									  _->
%% 										  nothing
%% 								  end;
%% 							  true->
%% 								  nothing
%% 						  	end;
%% 						  	true->
%% 								nothing
%% 						  end
%% 						  end,AchieveParts)
%% 	end,
	

achieve_init()->
	case get(achieve_role) of
		[]->
			InitAchieves = [];
		AchieveRole->
			{_,{{S,CC,PP},CurTargets}} = AchieveRole,
			InitAchieveFun = fun({{C,P},Finished,Status},Acc)->
						case Status of 
							0->
								if
									Finished =/= 0->
										case lists:keyfind({C,P}, 1, get(achieve)) of
											false->
												Acc;
											{_,_,_,Target,_,_,_,_}->
												[{_,_,Count}]=Target,
												Acc ++ [{Status,C,P,Finished,Count}]
										end;
									true->
										Acc
								end;
							_->
								case get(achieve) of
									?ERLNULL->noting;
									[]->nothing;
									Achieves->
										put(achieve,lists:keydelete({C,P}, 1, Achieves))
								end,
								Acc ++ [{Status,C,P,0,0}]
						end
					 end,
			InitAchieves = lists:foldl(InitAchieveFun, [{S,CC,PP,0,0}], CurTargets)
	end,
	send_achieve_init(InitAchieves),
	check_chapter_finished().
	
send_achieve_init(InitAchieves)->
	InitAchievesRecord = util:term_to_record_for_list(InitAchieves, ach),
	InitMessage = achieve_packet:encode_achieve_init_s2c(InitAchievesRecord),
	role_op:send_data_to_gate(InitMessage).

send_achieve_update(AchievePart)->
	AchievePartRecord = util:term_to_record(AchievePart,ach),
	UpdateMessage = achieve_packet:encode_achieve_update_s2c(AchievePartRecord),
	role_op:send_data_to_gate(UpdateMessage).

hook_on_swap_equipment(_SrcSlot,DesSlot,SrcInfo,DesInfo)->
	case package_op:where_slot(DesSlot) of
		body->
			Quality = get_qualty_from_iteminfo(SrcInfo),
			Star = get_enchantments_from_iteminfo(SrcInfo),
			Inventory = get_inventorytype_from_iteminfo(SrcInfo),
			Sockets = case get_socketsinfo_from_iteminfo(SrcInfo) of
						[]->
							[0];
						_->
							[0,0]
					  end;							
		_->
			if
				DesInfo =:= []->
					Quality = 0,
					Star = 0,
					Inventory = 0,
					Sockets = [0];
				true->
					Quality = get_qualty_from_iteminfo(DesInfo),
					Star = get_enchantments_from_iteminfo(DesInfo),
					Inventory = get_inventorytype_from_iteminfo(DesInfo),
					Sockets = case get_socketsinfo_from_iteminfo(DesInfo) of
								[]->
									[0];
								_->
									[0,0]
					  		  end
			end	
	end,			
	achieve_update({body_equipment},[Quality]),
	achieve_update({enchantments},[Star]),
	achieve_update({inlay},Sockets),
	achieve_update({enchant},[Quality]),
	achieve_update({target_equipment},[Inventory]),
	achieve_update({target_enchant},[Inventory]),
	role_attr_update().

role_attr_update()->
	{Meleedefense,Rangedefense,Magicdefense} = get_defenses_from_roleinfo(get(creature_info)),
	achieve_update({power},[0],get_power_from_roleinfo(get(creature_info))),
	achieve_update({hpmax},[0],get_hpmax_from_roleinfo(get(creature_info))),
	achieve_update({defense},[0],Meleedefense + Rangedefense + Magicdefense),
	achieve_update({fighting_force},[0],get_fighting_force_from_roleinfo(get(creature_info))).

hook_on_swap_pet_equipment(Quality)->
	achieve_op:achieve_update({pet_equipment},[Quality]).

chess_spirit_team(CurSection)->
	achieve_op:achieve_update({chess_spirit_team},[0],[CurSection]).
%%
%% Local Functions
%%
count_function(AchieveId,_Match,Count,MsgValue)->
	case get(achieve_role) of
		[]->
			nothing;
		AchieveRole->
			{MyRoleId,{Chapter,ChapterTargets}} = AchieveRole,
			case lists:keyfind(AchieveId, 1, ChapterTargets) of
				false->
					nothing;
				Target->
					{C,P} = AchieveId,
					{_,Finished,Status} = Target,
					if 
						Status=:=0,Finished+MsgValue>=Count->
							AchieveRoleUpdate={MyRoleId,{Chapter,lists:keyreplace(AchieveId, 1, ChapterTargets, {AchieveId,Finished+MsgValue,2})}},
							achieve_db:sync_update_achieve_role_to_mnesia(MyRoleId,AchieveRoleUpdate),
							put(achieve_role,AchieveRoleUpdate),
							put(achieve,lists:keydelete(AchieveId, 1, get(achieve))),
							send_achieve_update({2,C,P,0,0});
						true->
							AchieveRoleUpdate={MyRoleId,{Chapter,lists:keyreplace(AchieveId, 1, ChapterTargets, {AchieveId,Finished+MsgValue,0})}},
							achieve_db:async_update_achieve_role_to_mnesia(MyRoleId,AchieveRoleUpdate),
							put(achieve_role,AchieveRoleUpdate),
							send_achieve_update({0,C,P,Finished+MsgValue,Count})
					end
			end
	end.

match_function(AchieveId,_Match,TargetMatch,Count,_MsgValue,Script)->
	case get(achieve_role) of
		[]->
			nothing;
		AchieveRole->
			{MyRoleId,{Chapter,ChapterTargets}} = AchieveRole,
			case lists:keyfind(AchieveId, 1, ChapterTargets) of
				false->
					nothing;
				Target->
					{C,P} = AchieveId,
					{_,Finished,Status} = Target,
					if 
						Status=:=0->
							case check_part_is_finished(AchieveId,TargetMatch,Script) of
								{true,MatchResult}->
									AchieveRoleUpdate={MyRoleId,{Chapter,lists:keyreplace(AchieveId, 1, ChapterTargets, {AchieveId,MatchResult,2})}},
									achieve_db:sync_update_achieve_role_to_mnesia(MyRoleId,AchieveRoleUpdate),
									put(achieve_role,AchieveRoleUpdate),
									put(achieve,lists:keydelete(AchieveId, 1, get(achieve))),
									send_achieve_update({2,C,P,0,0});
								{false,MatchResult}->
									if 
										MatchResult>Finished->
											AchieveRoleUpdate={MyRoleId,{Chapter,lists:keyreplace(AchieveId, 1, ChapterTargets, {AchieveId,MatchResult,0})}},
											achieve_db:async_update_achieve_role_to_mnesia(MyRoleId,AchieveRoleUpdate),
											put(achieve_role,AchieveRoleUpdate),
											send_achieve_update({0,C,P,MatchResult,Count});
										true->
											nothing
									end;
								_->
									nothing
							end;
						true->
							nothing
					end
			end
	end.

matchnum_function(AchieveId,_Match,Count,MsgValue)->
	case get(achieve_role) of
		[]->
			nothing;
		AchieveRole->
			{MyRoleId,{Chapter,ChapterTargets}} = AchieveRole,
			case lists:keyfind(AchieveId, 1, ChapterTargets) of
				false->
					nothing;
				Target->
					{C,P} = AchieveId,
					{_,_,Status} = Target,
					if 
						Status=:=0,MsgValue>=Count->
							AchieveRoleUpdate={MyRoleId,{Chapter,lists:keyreplace(AchieveId, 1, ChapterTargets, {AchieveId,0,2})}},
							achieve_db:sync_update_achieve_role_to_mnesia(MyRoleId,AchieveRoleUpdate),
							put(achieve_role,AchieveRoleUpdate),
							put(achieve,lists:keydelete(AchieveId, 1, get(achieve))),
							send_achieve_update({2,C,P,0,0});
						true->
							nothing
					end
			end
	end.

exec_beam(Mod,Fun,AchieveId,Target)->
	try 
		Mod:Fun(AchieveId,Target) 
	catch
		Errno:Reason -> 	
			slogger:msg("exec_beam error Script : ~p fun:~p AchieveId: ~p Target: ~p ~p:~p ~n",[Mod,Fun,AchieveId,Target,Errno,Reason]),
			false
	end.	
