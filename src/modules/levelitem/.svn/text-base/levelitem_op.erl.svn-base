-module(levelitem_op).

-include("common_define.hrl").
-include("error_msg.hrl").
-include("logger.hrl").
-include("webgame.hrl").
-include("levelitem.hrl").
%% -define(ldebug, true).
%% items=[{template_id, num}]

-export([get_items_by_id/1, hook_level_award_item/2, export_for_copy/0, load_by_copy/1]).

% test
%-export([test1/0]).

-define(ROLEDATA, role_levelitem).
-record(item_hist,{template_id,num}).
-record(award_hist,{id,items,available}).
%%%===================================================================
%%%  CALLBACK
%%%===================================================================
%%%===================================================================
%%%  API
%%%===================================================================
hook_level_award_item(Level,all) ->
  {_, _, Logs} = levelitem_db:get_role_levelitem_info(get(roleid)),
  case get_level_award_list(Level,Logs) of
    [] -> 
      %slogger:msg("none can receive:~p~n",[Level]),
      skip;
    ShowList ->
      %slogger:msg("ShowList:~p~n",[ShowList]),
	  Hist = get_all_level_item_state(ShowList),
	  put(?LEVEL_ITEM, lists:keysort(1, get_level_item_temp(Hist))),
      role_op:send_data_to_gate(levelitem_packet:encode_level_award_item_s2c(Hist))
  end;
hook_level_award_item(Level,_) ->
	{_,_,Logs} = levelitem_db:get_role_levelitem_info(get(roleid)),
	case get_level_award_list(Level,Logs) of
		[] -> 
			%slogger:msg("none can receive:~p~n",[Level]),
			skip;
%		[#levelitem{show_level=S,obtain_level=O}|_]=ShowList ->
		ShowList ->
%			case Level =:= S orelse Level =:= O of
%				false -> skip;
%				true ->
					%slogger:msg("ShowList:~p~n",[ShowList]),
					Hist = get_all_level_item_state(ShowList),
					LevelItemTempList = lists:keysort(1, get_level_item_temp(Hist)),
					case LevelItemTempList =:= get(?LEVEL_ITEM) of
						true ->
							ok;
						false ->
							put(?LEVEL_ITEM, LevelItemTempList),
							role_op:send_data_to_gate(levelitem_packet:encode_level_award_item_s2c(Hist))
					end
%			end
	end.

get_items_by_id(Id)->
  {_TableName,RoleId,Logs} = levelitem_db:get_role_levelitem_info(get(roleid)),
  case get_level_award_list(get(level),Logs) of
    [] -> skip;
    AllList ->
      case lists:keyfind(Id,#levelitem.obtain_level,AllList) of
        false -> skip;
        Award ->
          case get(level) >= Award#levelitem.obtain_level of
            false -> skip;
            true -> add_award(Award,RoleId,Logs)
          end
      end
  end.

%%%===================================================================
%%%  INTERNAL 
%%%===================================================================
get_level_award_list(Level,Logs) ->
  Fun = fun(#levelitem{show_level=Id}=Award,Acc0) ->
      case lists:member(Id,Logs) of
        false -> [Award|Acc0];
        true -> Acc0
      end
  end,
  lists:foldl(Fun,[],levelitem_db:item(Level)). 

add_award(#levelitem{show_level=Id, items=Items},RoleId,Logs) ->
  case package_op:can_added_to_package_template_list(Items) of
    true -> 
      role_op:add_items_to_bag(Items, level_award),
      NewLogs = [Id|Logs],
      levelitem_db:save_role_levelitem_info(RoleId,NewLogs),
	  put(?LEVEL_ITEM, lists:keydelete(Id, 1, get(?LEVEL_ITEM)));
    _ -> 
      Msg = pet_packet:encode_send_error_s2c(?ERROR_PACKAGE_FULL),
			role_op:send_data_to_gate(Msg)
  end.

% 计算玩家本等级对应可领奖励等级状态及获取对应奖励物品
get_all_level_item_state(ShowList) ->
	Fun = fun(#levelitem{obtain_level=ObtainLevel, items=Items}) ->
			Available = case get(level) >= ObtainLevel of
				true -> 1;
				false ->0
			end,
			DO = fun({TemplateId,Num}) ->
					#item_hist{template_id=TemplateId, num=Num}
			end,
			ItemHist = [DO(Y)||Y<-Items],
			#award_hist{id = ObtainLevel, items = ItemHist, available = Available}
	end,
	[Fun(X)||X<-ShowList].

get_level_item_temp(Hist) ->
	[{AwardHist#award_hist.id, AwardHist#award_hist.available} || AwardHist <- Hist].

export_for_copy() ->
	get(?LEVEL_ITEM).

load_by_copy(Info) ->
	put(?LEVEL_ITEM, Info).
% test
%test1() ->
%	show(),
%	L = random:uniform(10),
%	get_gold_by_level(L).
