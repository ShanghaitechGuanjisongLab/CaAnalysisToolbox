function Overall = BlockyMedian(Overall)
for b=1:numel(Overall)
	Overall{b}=median(Overall{b},3);
end
Overall=cat(3,Overall{:});