%% Author: Administrator
%% Created: 2011-5-6
%% Description: TODO: Add description to path
-module(path).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([random_pos/1,path_find/3,path_find/6,check_around_nodes/4,distance/2,make_path/4,get_around_nodes/2]).

%%
%% API Functions
%%


%% make random pos  
%% random_pos()-> {Random_X,Random_Y}
random_pos(MapId)->
	MapDbName = mapdb_processor:make_db_name(MapId),
	case mapdb_processor:query_map_board(MapDbName) of
		{X,Y}->
			is_can_stand_pos(X,Y,MapDbName);
		{}->
			is_can_stand_pos(200,200,MapDbName);
		ERROR->
			is_can_stand_pos(200,200,MapDbName)
	end. 


is_can_stand_pos(X,Y,MapDbName)->
	Random_X = random:uniform(X),
	Random_Y = random:uniform(Y),
		case mapdb_processor:query_map_stand(MapDbName,{Random_X,Random_Y}) of
			1 ->
				is_can_stand_pos(X,Y,MapDbName);
			_ ->
				{Random_X,Random_Y}
		end.


%%
%% Local Functions
%%

distance(Begin,End)->
	{BeginX,BeginY} = Begin,
	{EndX,EndY} = End,
	Distance = ((BeginX-EndX)*(BeginX-EndX)+(BeginY-EndY)*(BeginY-EndY))*100,
	Distance.


%%
%%make the path to end pos
%%

%%
%% WaitCheckNodeList = [{point,parentpoint,f,g,h}]
%%

make_path(Path,PresentNode,HadCheckNodeList,Begin)->
	{PresentPoint,ParentPoint,_,_,_} = PresentNode,
	case PresentPoint of
		Begin->
			Path;
		_->
			case lists:keysearch(ParentPoint, 1, HadCheckNodeList) of 
				{value,ParentNode}->
					make_path([PresentPoint|Path],ParentNode,HadCheckNodeList,Begin);
				false->
					[]
			end
	end.
		
	
get_around_nodes(PresentNode,End)->
	{{X,Y},_,_,G,_} = PresentNode,
	 [{{X-1,Y},{X,Y},G+10+distance({X-1,Y},End),G+10,distance({X-1,Y},End)},
      {{X,Y-1},{X,Y},G+10+distance({X,Y-1},End),G+10,distance({X,Y-1},End)},
	  {{X+1,Y},{X,Y},G+10+distance({X+1,Y},End),G+10,distance({X+1,Y},End)},
	  {{X,Y+1},{X,Y},G+10+distance({X,Y+1},End),G+10,distance({X,Y+1},End)},
	  {{X-1,Y-1},{X,Y},G+14+distance({X-1,Y-1},End),G+14,distance({X-1,Y-1},End)},
	  {{X+1,Y-1},{X,Y},G+14+distance({X+1,Y-1},End),G+14,distance({X+1,Y-1},End)},
	  {{X-1,Y+1},{X,Y},G+14+distance({X-1,Y+1},End),G+14,distance({X-1,Y+1},End)},
	  {{X+1,Y+1},{X,Y},G+14+distance({X+1,Y+1},End),G+14,distance({X+1,Y+1},End)}].
 	

	


%% check around nodes if can stand or in WaitCheckNodeList or in HadCheckNodeList
check_around_nodes(WaitCheckNodeList,_HadCheckNodeList,_MapDbName,[])->	
	lists:keysort(5, WaitCheckNodeList);
	
check_around_nodes(WaitCheckNodeList,HadCheckNodeList,MapDbName,[HNode|TNodes])->
	{{X,Y},_,_,G,_} = HNode,
	case mapdb_processor:query_map_stand(MapDbName,{X,Y}) of
		1->
			check_around_nodes(WaitCheckNodeList,HadCheckNodeList,MapDbName,TNodes);
		_->
			case lists:keyfind({X,Y},1,WaitCheckNodeList) of
				{{X,Y},_,_,OldG,_}->
					if G>=OldG->
						   check_around_nodes(WaitCheckNodeList,HadCheckNodeList,MapDbName,TNodes);
					   true->
						   NewWaitCheckNodeList = lists:keyreplace({X,Y},1,WaitCheckNodeList,HNode),
						   check_around_nodes(NewWaitCheckNodeList,HadCheckNodeList,MapDbName,TNodes)
					end;
				false->
					case lists:keyfind({X,Y},1,HadCheckNodeList) of 
						{{X,Y},_,_,_,_}->
							check_around_nodes(WaitCheckNodeList,HadCheckNodeList,MapDbName,TNodes);
						false->
							check_around_nodes([HNode|WaitCheckNodeList],HadCheckNodeList,MapDbName,TNodes)
					end
			end
	end.
	

%%
%%the main code about path find
%%

path_find(Begin,End,MapId)->
	try
		MapDbName = mapdb_processor:make_db_name(MapId),
		StartNode = {Begin,{},distance(Begin,End),0,distance(Begin,End)},
		path_find(Begin,End,StartNode,[StartNode],[],MapDbName)
	catch
		E:R ->
			slogger:msg("E:~pR:~p~n",[E,R]),
			[]
	end.


path_find(Begin,End,ParentNode,[],HadCheckNodeList,MapDbName)->
	[];

path_find(Begin,End,ParentNode,WaitCheckNodeList,HadCheckNodeList,MapDbName)->	
	[LeastCostNode|NWaitCheckNodeList] = WaitCheckNodeList,
	case LeastCostNode of
		{End,_,_,_,_}->
			 make_path([],LeastCostNode,HadCheckNodeList,Begin);
		{_,_,_,_,_}->
			NewHadCheckNodeList = [LeastCostNode|HadCheckNodeList],
			AroundNodes=get_around_nodes(ParentNode,End),
			NewWaitCheckNodeList = check_around_nodes(NWaitCheckNodeList,HadCheckNodeList,MapDbName,AroundNodes), 	
			path_find(Begin,End,LeastCostNode,NewWaitCheckNodeList,NewHadCheckNodeList,MapDbName);
		ERROR->
			slogger:msg("path_find,error:~p~n",[ERROR]),
			[]
	end.



  

