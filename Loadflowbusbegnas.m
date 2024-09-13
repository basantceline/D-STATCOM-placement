 clc;
clear all;
format short;
m=load('loaddata.m');
l=load('linedata.m');
br=length(l);
no=length(m)
f=0;
d=0;
MVAb=100;
KVb=11;
Zb=(KVb^2)/MVAb;
Pg = zeros(no,1);
Pg1 = zeros(no,1);
 
for i=1:br
    R(i,1)=(l(i,4))/Zb;
    X(i,1)=(l(i,5))/Zb;
end
for i=1:no
    P(i,1)=(m(i,2)/(1000*MVAb));
    Q(i,1)=(m(i,3)/(1000*MVAb));
end
R;
X;
P;
Q;

C=zeros(br,no);
for i=1:br
    a=l(i,2);
    b=l(i,3);
    for j=1:no
        if a==j
            C(i,j)=-1;
        end
        if b==j
            C(i,j)=1;
        end
    end
end
C;
e=1;
for i=1:no
    d=0;
    for j=1:br
        if C(j,i)==-1
            d=1;
        end
    end
    if d==0
        endnode(e,1)=i;
        e=e+1;
    end
end
endnode;
h=length(endnode);
for j=1:h
    e=2;
    
    f=endnode(j,1);
   % while (f~=1)
   for s=1:no
     if (f~=1)
       k=1;  
       for i=1:br
           if ((C(i,f)==1)&&(k==1))
                f=i;
                k=2;
           end
       end
       k=1;
       for i=1:no
           if ((C(f,i)==-1)&&(k==1));
                f=i;
                g(j,e)=i;
                e=e+1;
                k=3;
           end            
       end
     end
   end
end
for i=1:h
    g(i,1)=endnode(i,1);
end
g;
w=length(g(1,:));
for i=1:h
    j=1;
    for k=1:no 
        for t=1:w
            if g(i,t)==k
                g(i,t)=g(i,j);
                g(i,j)=k;
                j=j+1;
             end
         end
    end
end
g;
for k=1:br
    e=1;
    for i=1:h
        for j=1:w-1
            if (g(i,j)==k) 
                if g(i,j+1)~=0
                    adjb(k,e)=g(i,j+1);            
                    e=e+1;
                else
                    adjb(k,1)=0;
                end
             end
        end
    end
end
adjb;
for i=1:br-1
    for j=h:-1:1
        for k=j:-1:2
            if adjb(i,j)==adjb(i,k-1)
                adjb(i,j)=0;
            end
        end
    end
end
adjb;
x=length(adjb(:,1));
ab=length(adjb(1,:));
for i=1:x
    for j=1:ab
        if adjb(i,j)==0 && j~=ab
            if adjb(i,j+1)~=0
                adjb(i,j)=adjb(i,j+1);
                adjb(i,j+1)=0;
            end
        end
        if adjb(i,j)~=0
            adjb(i,j)=adjb(i,j)-1;
        end
    end
end
adjb;
for i=1:x-1
    for j=1:ab
        adjcb(i,j)=adjb(i+1,j);
    end
end
b=length(adjcb);

% voltage current program

for i=1:no
    vb(i,1)=1;
end
for s=1:10
for i=1:no
    nlc(i,1)=conj(complex(P(i,1),Q(i,1)))/(vb(i,1));
end
nlc;
for i=1:br
    Ibr(i,1)=nlc(i+1,1);
end
Ibr;
xy=length(adjcb(1,:));
for i=br-1:-1:1
    for k=1:xy
        if adjcb(i,k)~=0
            u=adjcb(i,k);
            Ibr(i,1)=Ibr(i,1)+Ibr(u,1);
        end
    end      
end
Ibr;
for i=2:no
      g=0;
      for a=1:b 
          if xy>1
            if adjcb(a,2)==i-1 
                u=adjcb(a,1);
                vb(i,1)=((vb(u,1))-((Ibr(i-1,1))*(complex((R(i-1,1)),X(i-1,1)))));
                g=1;
            end
            if adjcb(a,3)==i-1 
                u=adjcb(a,1);
                vb(i,1)=((vb(u,1))-((Ibr(i-1,1))*(complex((R(i-1,1)),X(i-1,1)))));
                g=1;
            end
          end
        end
        if g==0
            vb(i,1)=((vb(i-1,1))-((Ibr(i-1,1))*(complex((R(i-1,1)),X(i-1,1)))));
        end
end
s=s+1;
end
nlc;
Ibr;
vb;
vbp=[abs(vb)];

for i=1:no
    va(i,2)=vbp(i,1);
end
for i=1:no
    va(i,1)=i;
    P1(i) = P(i);
    Q1(i) = Q(i);
end

va;
Ibrp=[abs(Ibr)];
PL(1,1)=0;
QL(1,1)=0;

% losses at base case 
for f=1:br
    Pl(f,1)=(Ibrp(f,1)^2)*R(f,1);
    Ql(f,1)=X(f,1)*(Ibrp(f,1)^2);
    PL(1,1)=PL(1,1)+Pl(f,1);
    QL(1,1)=QL(1,1)+Ql(f,1);
end

Plosskw=(Pl)*100000;
Qlosskw=(Ql)*100000;
PL=(PL)*100000
QL=(QL)*100000

voltage = vbp(:,1)
v_mag = va(:,2);
% for plotting bar and formatting the graph
bus=1:1:72;
bus=bus.';
bar(bus,voltage,0.2)
xticks(bus);
xlabel('Bus');
ylabel('Voltage in pu');
ylim([0 1.1]);
% for plotting bar and formatting the graph
bus=1:1:no;
bus=bus.';
pBus= bus(2:end);  
%subplot(2,1,1)
bar(pBus,Plosskw);
xticks(pBus);
xticklabels({'1-2','2-3','3-4','4-5','5-6','4-7','7-8','8-9','9-10','7-11','11-12','12-13','13-14','13-15','15-16','16-17','17-18','16-19','19-20','19-21','21-22','22-23','23-24','24-25','25-26','25-27','27-28','28-29','29-30','30-31','31-32','32-33','33-34','34-35','35-36','33-37','37-38','38-39','39-40','40-41','41-42','42-43','43-44','44-45','45-46','43-47','47-48','48-49','49-50','50-51','51-52','52-53','53-54','54-55','54-56','56-57','40-58','58-59','59-60','60-61','61-62','62-63','61-64','64-65','65-66','66-67','67-68','68-69','69-70','70-71','71-72'})
xlabel('Branch');
ylabel('Active Power loss (Kw)');
%ylim([0 1.1]);
%subplot(2,1,2)
figure()
bar(bus,voltage,0.5);
xticks(bus);
xlabel('Bus');
ylabel('Voltage in pu');
ylim([0 1.1]);
figure()
bar(pBus,Qlosskw);
xticks(pBus);
xticklabels({'1-2','2-3','3-4','4-5','5-6','4-7','7-8','8-9','9-10','7-11','11-12','12-13','13-14','13-15','15-16','16-17','17-18','16-19','19-20','19-21','21-22','22-23','23-24','24-25','25-26','25-27','27-28','28-29','29-30','30-31','31-32','32-33','33-34','34-35','35-36','33-37','37-38','38-39','39-40','40-41','41-42','42-43','43-44','44-45','45-46','43-47','47-48','48-49','49-50','50-51','51-52','52-53','53-54','54-55','54-56','56-57','40-58','58-59','59-60','60-61','61-62','62-63','61-64','64-65','65-66','66-67','67-68','68-69','69-70','70-71','71-72'})
xlabel('Branch');
ylabel('Reactive Power loss (KVAR)');