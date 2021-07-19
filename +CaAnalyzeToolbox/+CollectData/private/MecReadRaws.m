function Measurements = MecReadRaws(Path,SizeT)
try
	if SizeT<65535
		Measurements=load(Path).Measurements(:,1:SizeT);
	else
		Measurements=load(Path).Measurements;
	end
catch
	clipboard("copy",Path);
	error(Path+"存在问题，请检查。路径已复制到剪贴板。");
end