function Overall = BlockySubDff0(Overall,SamplePoints,BaseSamples)
for b=1:numel(Overall)
	Block=Overall{b};
	Overall{b}=median(Block(:,SamplePoints,:)./mean(Block(:,BaseSamples,:),2),3);
end
Overall=cat(3,Overall{:});