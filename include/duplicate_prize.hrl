% 副本奖励配置文件结构
-record(duplicate_prize_config, {
		duplicate_id,			% 副本id
		prize_list				% [{IndexId, Rate, ItemTemplicateId, Num}, .......]
	}).
