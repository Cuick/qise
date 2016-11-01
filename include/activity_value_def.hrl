%%
%%模板表
%%com_condition = {{msg,value},op,targetvalue}
%% {activity_value_proto,208,7,2,[],{{instance,10000},eq,1},10,0}.
%%
-record(activity_value_proto,{
	id,			% id
	type,		% 类型
	maxtimes,	% 参与最大次数
	time,		% 开启时间
	com_condition, % 自定义条件
	value,			% 值
	targetid		% 目标
}).

%%
%%奖励模板表
%%
-record(activity_value_reward,{value,reward}).

-record(role_activity_value,{roleid,state,value,reward}).
