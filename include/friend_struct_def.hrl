-record(friend,{owner,fid,fname,finfo,intimacy,status}).
-record(signature,{roleid,sign}).
-record(black,{owner,fid,fname,finfo,status}).

-define(BILATERAL_FRIENDS, 0).
-define(UNILATERAL_FRIEND, 1).
-define(BILATERAL_BLACKS, 2).