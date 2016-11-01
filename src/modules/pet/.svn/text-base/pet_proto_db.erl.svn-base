%%
-module(pet_proto_db).

%% 
%% Include
%% 
-include("pet_def.hrl").

-define(PET_PROTO_ETS,pet_proto_ets).

-compile(export_all).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(pet_proto,record_info(fields,pet_proto),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_proto,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?PET_PROTO_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(pet_proto, ?PET_PROTO_ETS,#pet_proto.protoid).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% get_info()
%% []
%% {...}
%%[error,....]
%%
get_info(Id)->
	case ets:lookup(?PET_PROTO_ETS,Id) of
		[]->[];
		[{_Id,Value}] -> Value
	end.

%%
%%	 return : Value | []
%%
get_name(ProtoInfo)->
	element(#pet_proto.name,ProtoInfo).


get_species(ProtoInfo)->
	element(#pet_proto.species,ProtoInfo).
%%
%%	 return : Value | []
%%
get_femina_rate(ProtoInfo)->
	element(#pet_proto.femina_rate,ProtoInfo).

%%
%%	 return : Value | []
%%
get_class(ProtoInfo)->
	element(#pet_proto.class,ProtoInfo).

%%
%%	 return : Value | []
%%
get_min_take_level(ProtoInfo)->
	element(#pet_proto.min_take_level,ProtoInfo).

%%
%%	 return : Value | []
%%
get_quality_to_growth(ProtoInfo)->
	element(#pet_proto.quality_to_growth,ProtoInfo).
	
%%
%%	 return : Value | []
%%							
get_born_abilities(ProtoInfo)->
	element(#pet_proto.born_abilities,ProtoInfo).
	
%%
%%	 return : Value | []
%%							
get_born_talents(ProtoInfo)->
	element(#pet_proto.born_talents,ProtoInfo).


%%
%%	 return : Value | []
%%
get_born_skills(ProtoInfo)->
	element(#pet_proto.born_skills,ProtoInfo).

%%
%% return : Value | []
%%
get_born_attr(ProtoInfo)->
	element(#pet_proto.born_attr,ProtoInfo).

%%
%% return : Value | []
%%
get_happiness_cast(ProtoInfo)->
	element(#pet_proto.happiness_cast,ProtoInfo).

%%
%% return : Value | []
%%
get_born_quality(ProtoInfo)->
	element(#pet_proto.born_quality,ProtoInfo).

%%
%% return : Value | []
%%
get_born_quality_up(ProtoInfo)->
	element(#pet_proto.born_quality_up,ProtoInfo).

%%
%% return : Value | []
%%
get_can_delete(ProtoInfo)->
	element(#pet_proto.can_delete,ProtoInfo).

%%
%% return : Value | []
%%
get_can_explore(ProtoInfo)->
	element(#pet_proto.can_explore,ProtoInfo).
		
% get_is_ride(ProtoInfo) ->
%    element(#pet_proto.is_ride,ProtoInfo).
