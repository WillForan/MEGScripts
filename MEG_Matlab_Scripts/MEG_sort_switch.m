function ov = MEG_sort_switch(input,output)
% sort switch, non-switch trials
% recode events from mix paradigm's event file


X=load(input);
Z=X;
[a,b]=size(X);
ANTI=[25,35];
VGS=[65,75];

for r = 3:1:(a)
    if X(r,4)==250
        continue
    end
    if any(X(r,4)==ANTI) && any(X(r-2,4)==ANTI)
        Z(r,4)=11;
    end
    if any(X(r,4)==ANTI) && any(X(r-2,4)==VGS)
        Z(r,4)=1;
    end
    if any(X(r,4)==VGS) && any(X(r-2,4)==VGS)
        Z(r,4)=22;
    end
    if any(X(r,4)==VGS) && any(X(r-2,4)==ANTI)
        Z(r,4)=2;
    end
    
   
end
ov=Z;

dlmwrite(output,ov,'\t');
    
