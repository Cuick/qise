-module(broadcast_op).
-author("zhuo.yan").
-include("pet_struct.hrl").
-include("mnesia_table_def.hrl").
-include("guild_define.hrl").

-compile(export_all).

%%%===================================================================
%%%  COMMON
%%%===================================================================
broadcast_gate(ChatId, Info) ->
  RoleInfo = get(creature_info),
  ParamRole = system_chat_util:make_role_param(RoleInfo),
  MsgInfo = [ParamRole|Info],
  slogger:msg("broadcast_op0: ~p ~p ~n", [ChatId, MsgInfo]),
  system_chat_op:system_broadcast(ChatId,MsgInfo).

item_quality(ItemId) ->
  case item_template_db:get_item_templateinfo(ItemId) of
    [] -> 0;
    Info -> item_template_db:get_qualty(Info)
  end.

item_level(ItemId) ->
  case item_template_db:get_item_templateinfo(ItemId) of
    [] -> 0;
    Info -> item_template_db:get_level(Info)
  end.

pet_quality(ItemId) ->
  case item_template_db:get_item_templateinfo(ItemId) of
    [] -> 0;
    Info -> case item_template_db:get_states(Info) of
              [{_, Quality}] -> Quality;
              _ -> 0
            end
  end.

chatid(Key, F) ->
  case broadcast_db:config(Key) of
    nothing -> nothing;
    Option ->
       #broadcast{condition=Condition, chatid=ChatId} = Option,
       case erlang:length(Condition) /= 0 of
          false -> ChatId;
          true ->
            case lists:any(F, Condition) of
              false -> nothing;
              true -> ChatId
            end
       end
  end.

%%%===================================================================
%%%  API
%%%===================================================================

% mall
buy_item(ItemId, Price) ->
  slogger:msg("Itemid: [~p], Price: [~p]", [ItemId, Price]),
  F = fun({gold, Gold}) ->
          Price >= Gold;
         (_) -> false
      end,
  case chatid(mall, F) of
    nothing -> nothing;
    ChatId ->
      Info = system_chat_util:make_item_param(ItemId),
      broadcast_gate(ChatId, [Info])
  end.

buy_item2(ItemId, Price) ->
  slogger:msg("Itemid2: [~p], Price2: [~p]", [ItemId, Price]),
  F = fun({gold, Gold}) ->
          Price >= Gold;
         (_) -> false
      end,
  case chatid(mall2, F) of
    nothing -> slogger:msg("2Itemid: [~p], Price: [~p]", [ItemId, Price]),nothing;
    ChatId ->
      Info = system_chat_util:make_item_param(ItemId),
      broadcast_gate(ChatId, [Info])
  end.


% temp_activity
get_reward(RewardList) ->
  % RewardList :: [{item_id, num}]
  case broadcast_db:get_chatid(activity) of
    nothing -> ok;
    ChatId ->
      [(fun({ItemId, Count}) ->
        Info1 = system_chat_util:make_item_param(ItemId),
        Info2 = system_chat_util:make_int_param(Count),
        broadcast_gate(ChatId, [Info1|Info2])
       end)(Reward)
      || Reward <- RewardList ]
  end.

% get_charge_package
get_charge_package(Id) ->
  case broadcast_db:get_chatid(charge_package) of
    nothing -> ok;
    ChatId ->
      Info = system_chat_util:make_int_param(Id),
      broadcast_gate(ChatId, [Info])
  end.

% treasure
treasure_count(UCount) ->
  F = fun({count, Count}) ->
        Count == UCount;
        (_) -> false
      end,
  case chatid(treasure_count, F) of
    nothing -> ok;
    ChatId ->
      Info = system_chat_util:make_int_param(UCount),
      broadcast_gate(ChatId, [Info])
  end.

treasure_chest(ItemId, Count) ->
  F =fun({quality, Quality}) ->
        item_quality(ItemId) == Quality;
        (_) -> false
     end,
  case chatid(treasure_chest, F) of
    nothing -> ok;
    ChatId ->
      slogger:msg("broadcast_op, treasure_chest ~p ~p", [item_quality(ItemId)]),
      Info1 = system_chat_util:make_item_param(ItemId),
      Info2 = system_chat_util:make_int_param(Count),
      broadcast_gate(ChatId, [Info1|Info2])
  end.

god_tree_count(Times) ->
  F = fun({count, Count}) ->
        Count == Times;
        (_) -> false
      end,
  case chatid(god_tree_count, F) of
    nothing -> ok;
    ChatId ->
      Info = system_chat_util:make_int_param(Times),
      broadcast_gate(ChatId, [Info])
  end.

%% pet
% 紫品一阶以上
pet_quality_riseup(GmPetInfo, QualityStage) ->
  #gm_pet_info{id=PetId, name=PetName, quality=PetQuality} = GmPetInfo,
  slogger:msg("PetQuality ~p ~p", [PetQuality, QualityStage]),
  Key = "pet_quality_riseup" ++ erlang:integer_to_list(PetQuality),
  case broadcast_db:get_chatid(erlang:list_to_atom(Key)) of
    nothing -> ok;
    ChatId ->
      % Info1 = system_chat_util:make_pet_param(PetId, PetName, PetQuality, get(creature_info)),
      Info = system_chat_util:make_int_param(QualityStage),
      broadcast_gate(ChatId, [Info])
  end.

pet_grade(GmPetInfo, UGrade) ->
  #gm_pet_info{id=PetId, name=PetName, quality=PetQuality} = GmPetInfo,
  F = fun({grade, Grade}) ->
    UGrade rem Grade == 0;
    (_) -> false
  end,
  case chatid(pet_grade, F) of
    nothing -> slogger:msg("broadcast_op pet_grade fail valid ~p ~p", [GmPetInfo, UGrade]);
    ChatId ->
      % Info1 = system_chat_util:make_pet_param(PetId, PetName, PetQuality, get(creature_info)),
      Info = system_chat_util:make_int_param(UGrade),
      broadcast_gate(ChatId, [Info])
  end.

pet_reset(GmPetInfo, UAttrValue) when UAttrValue /= undefined ->
  put(broadcast_reset, undefined),
  #gm_pet_info{id=PetId, name=PetName, quality=PetQuality} = GmPetInfo,
  case broadcast_db:get_chatid(pet_reset) of
    nothing -> ok;
    ChatId ->
      % Info1 = system_chat_util:make_pet_param(PetId, PetName, PetQuality, get(creature_info)),
      broadcast_gate(ChatId, [])
  end;
pet_reset(_, _) -> slogger:msg("broadcast_op AttrValue undefined").

pet_refresh_check(_, [], _)  ->
  true;
pet_refresh_check([{ItemId, _} | Rest], Condition, ChatId) ->
  slogger:msg("Quality = ~p", [pet_quality(ItemId)]),
  Result = lists:any(
    fun({quality, Quality}) ->
        pet_quality(ItemId) >= Quality;
       (_) ->  false
    end,
    Condition
  ),
  case Result of
    false -> pet_refresh_check(Rest, Condition, ChatId);
    true ->
      Info = system_chat_util:make_item_param(ItemId),
      broadcast_gate(ChatId, [Info]),
      pet_refresh_check(Rest, Condition, ChatId)
  end;
pet_refresh_check([], _, _) ->
  false.

pet_refresh(PetShopGoodsList) when length(PetShopGoodsList) /= 0 ->
  % PetShopGoodsList :: [{itemid, price}]
  slogger:msg("pet shop goods list ~p~n", [PetShopGoodsList]),
  case broadcast_db:config(pet_refresh) of
    nothing -> ok;
    Config ->
      #broadcast{condition=Condition, chatid=ChatId} = Config,
      pet_refresh_check(PetShopGoodsList, Condition, ChatId)
  end;
pet_refresh(_) -> ok.

% role
% venation
venation_active(UPoint) ->
  slogger:msg("venation total: ~p ~n", [UPoint]),
  venation_active(check1, UPoint),
  venation_active(check2, UPoint).

venation_active(check1, UPoint) ->
  F = fun({point, Point}) ->
    UPoint rem Point == 0;
    (_) -> false
  end,
  case chatid(venation_active_attr, F) of
    nothing -> ok;
    ChatId ->
      Info = system_chat_util:make_int_param(UPoint),
      broadcast_gate(ChatId, [Info])
  end;
venation_active(check2, UPoint) ->
  F = fun({point, Point}) ->
    UPoint == Point;
    (_) -> false
  end,
  case chatid(venation_active_total, F) of
    nothing -> ok;
    ChatId ->
      Info = system_chat_util:make_int_param(UPoint),
      broadcast_gate(ChatId, [Info])
  end.

venation_advanced_attr(UPoint) ->
  slogger:msg("venation advanced point: ~p ~p ~n", [UPoint]),
  F = fun({point, Point}) ->
          UPoint rem Point == 0;
        (_) -> flase
      end,
  case chatid(venation_advanced_attr, F) of
    nothing -> ok;
    ChatId ->
      Info = system_chat_util:make_int_param(UPoint),
      broadcast_gate(ChatId, [Info])
  end.

% equipment_sock_c2s
equipment_punch(EquipTempId, UPunchNum) ->
  slogger:msg("equipment_punch ~~~p ~p ~n", [EquipTempId, UPunchNum]),
  F = fun({punchnum, PunchNum}) ->
      UPunchNum == PunchNum;
      (_) -> false
    end,
  case chatid(equipment_punch, F) of
    nothing -> ok;
    ChatId ->
      Info1 = system_chat_util:make_item_param(EquipTempId),
      broadcast_gate(ChatId, [Info1])
  end.

equipment_inlay(EquipTempId, USockNum) ->
  slogger:msg("equipment_inlay ~~~p ~p ~n", [EquipTempId, USockNum]),
  F = fun({socknum, SockNum}) ->
      USockNum == SockNum;
      (_) -> false
    end,
  case chatid(equipment_inlay, F) of
    nothing -> ok;
    ChatId ->
      Info1 = system_chat_util:make_item_param(EquipTempId),
      Info2 = system_chat_util:make_int_param(USockNum),
      broadcast_gate(ChatId, [Info1, Info2])
  end.

equipment_riseup(EquipTempId, ULevel) ->
  slogger:msg("equipment_riseup ~~~p ~p ~n", [EquipTempId, ULevel]),
  F = fun({level, Level}) ->
      ULevel == Level;
      (_) -> false
    end,
  case chatid(equipment_riseup, F) of
    nothing -> ok;
    ChatId->
      Info1 = system_chat_util:make_item_param(EquipTempId),
      Info2 = system_chat_util:make_int_param(ULevel),
      broadcast_gate(ChatId, [Info1, Info2])
  end.

equipment_stonemix(ItemId) ->
  F = fun({level, Level}) ->
      item_level(ItemId) >= Level;
      (_) -> false
    end,
  case chatid(equipment_stonemix, F) of
    nothing -> ok;
    ChatId ->
      Info = system_chat_util:make_item_param(ItemId),
      broadcast_gate(ChatId, [Info])
  end.


% guild
guild_create(GuildName) ->
  case broadcast_db:get_chatid(guild_create) of
    nothing -> ok;
    ChatId ->
      Info = system_chat_util:make_string_param(GuildName),
      broadcast_gate(ChatId, [Info])
  end.

% 帮会
guild_upgrade(?GUILD_FACILITY, GuildName, GuildLevel) ->
  case broadcast_db:get_chatid(guild_upgrade) of
    nothing -> ok;
    ChatId ->
      Info1 = system_chat_util:make_string_param(GuildName),
      Info2 = system_chat_util:make_int_param(GuildLevel),
      slogger:msg("broadcast_op guild upgrade : ~p ~p ~n", [ChatId, [Info1, Info2]]),
      system_chat_op:system_broadcast(ChatId, [Info1, Info2])
   end;
% 百宝阁
guild_upgrade(?GUILD_FACILITY_TREASURE, GuildName, GuildLevel) ->
  case broadcast_db:get_chatid(guild_upgrade_treasure) of
    nothing -> ok;
    ChatId ->
      Info1 = system_chat_util:make_string_param(GuildName),
      Info2 = system_chat_util:make_int_param(GuildLevel),
      slogger:msg("broadcast_op guild treasure upgrade : ~p ~p ~n", [ChatId, [Info1, Info2]]),
      system_chat_op:system_broadcast(ChatId, [Info1, Info2])
  end;
% 铁匠铺
guild_upgrade(?GUILD_FACILITY_SMITH, GuildName, GuildLevel) ->
  case broadcast_db:get_chatid(guild_upgrade_smith) of
    nothing -> ok;
    ChatId ->
      Info1 = system_chat_util:make_string_param(GuildName),
      Info2 = system_chat_util:make_int_param(GuildLevel),
      slogger:msg("broadcast_op guild smith upgrade : ~p ~p ~n", [ChatId, [Info1, Info2]]),
      system_chat_op:system_broadcast(ChatId, [Info1, Info2])
  end.

% goal
goals(Level) ->
  slogger:msg("goals level ~p", [Level]),
  Key = "goals" ++ erlang:integer_to_list(Level),
  slogger:msg("goals id ~p", [Key]),
  case broadcast_db:get_chatid(erlang:list_to_atom(Key)) of
    nothing -> slogger:msg("goals get charid nothing");
    ChatId ->
      broadcast_gate(ChatId, [])
  end.

% invite friend
invite_friend_success(Awards) ->
  % Awards :: [{ItemId, Num}]
  case broadcast_db:get_chatid(invite_friend_success) of
    nothing -> ok;
    ChatId ->
      [(fun({ItemId, Count}) ->
        Info1 = system_chat_util:make_item_param(ItemId),
        Info2 = system_chat_util:make_int_param(Count),
        broadcast_gate(ChatId, [Info1, Info2])
       end)(Award)
      || Award <- Awards]
  end.

% 指定物品广播
specify_item(ItemId) ->
	F = fun(CItemId) ->
			CItemId == ItemId
		end,
	case chatid(specify_item, F) of
		nothing -> slogger:msg("broadcast_op: failed to get config");
		ChatId ->
			Info = system_chat_util:make_item_param(ItemId),
			broadcast_gate(ChatId, [Info])
	end.

use_item(ItemId) ->
	F = fun(CItemId) ->
		CItemId == ItemId
	end,
	case chatid(use_item, F) of
		nothing -> slogger:msg("broadcast_op: failed to get config");
		ChatId ->
			Info = system_chat_util:make_item_param(ItemId),
			broadcast_gate(ChatId, [Info])
	end.

% test
move(Test) ->
  Price = random:uniform(1200),
  UQuality = random:uniform(5),
  F =
    fun({gold, Gold}) ->
          Price >= Gold;
      ({quality, Quality}) ->
            UQuality >= Quality;
      (Other) -> false
    end,
  case chatid(mall, F) of
    nothing -> slogger:msg("broadcast_op: failed to get config");
    ChatId ->
      Info = system_chat_util:make_int_param(10),
      slogger:msg("broadcast_op: ~p ~p ~n", [1103, [Info]]),
      % Info = system_chat_util:make_string_param("tester"),
      broadcast_gate(1103, [Info])
%%       slogger:msg("broadcast_op: ~p ~p ~n", [1128, [Info]]),
  end.

test() ->
	specify_item(10013101).
