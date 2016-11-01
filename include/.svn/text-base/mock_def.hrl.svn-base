-define (BORN_MAP_MALE, 100).
-define (BORN_MAP_FEMALE, 103).

-define (BORN_POS, {58, 112}).
-define (BORN_LEVEL, 1).
-define (BORN_PATH_ID, 1).

-define (BASE_ROLE_ID, 48000000).

-define (NAME_NOT_USE, 0).
-define (NAME_IN_USE, 1).

%% 站立不动的机器人
-record (mock_type_1, {id,level,map_id,pos}).

%% 机器人默认属性
-record (mock_base, {class,level,life,hpmax,mana,mpmax,exp,levelupexp,soulpower,maxsoulpower,agile,strength,intelligence,stamina,
	power,defenses,hitrate,dodge,criticalrate,criticaldamage,toughness,immunes,cloth,arm,
	crime,viptag,ride_display,fighting_force,eqipments,state}).

%% 跑路机器人
-record (mock_type_3, {id,level,wait_time,path,next_map}).

%% 随机喊话机器人
-record (mock_type_4, {id,msg}).

%% 广播刷屏机器人
-record (mock_type_5, {id,broadcasts,level}).

%% 七色乱斗机器人
-record (mock_type_6, {id,class,level,equipments,skills}).
-record (mock_path_type_6, {id,pos,path}).

%% 打怪机器人
-record (mock_type_2, {id,class,level,equipments,skills,map_id,pos,enemy_id}). 