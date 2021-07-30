function Overall = BlockyDff0(Overall,BaseSamples)
for b=1:numel(Overall)
	Block=Overall{b};
	Overall{b}=median(Block./mean(Block(:,BaseSamples,:),2),3);
end
Overall=cat(3,Overall{:});