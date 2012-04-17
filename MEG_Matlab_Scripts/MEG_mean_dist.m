function meanD =  MEG_mean_dist(head,fif)

 % fif is aquired by
 %[head,fif] = read_fiff(fif_filename);

 %% calculate position of censor for each step
 % in head coord of head sensors


 %  count=0; for i=1:length(h.info.chs); if(length(h.info.chs(i).coil_trans)>3);count=count+1;  a(count,:)=h.info.chs(i).coil_trans(1:3,4);end; end
 % disp([length(a) length(unique(a,'rows'))])
 %   306   102
 %  plot3(a(:,1),a(:,2),a(:,3),'k.')
 %
 %
 % sense_cords= [ x1 x2 x3 x4;
 %                y1 y2 y3 y4;
 %                z1 z2 z3 z4 ] ;
 %

 count=0; 
 for i=1:length(head.info.chs)
   trans=head.info.chs(i).coil_trans;
   if(length(trans)>3)
     count=count+1;  
     sense_cords(:,count)=trans(1:3,4)';
   end
 end

 % remove duplicate positions  (3 sesors at each position)
 sense_cords=unique(sense_cords','rows')';

 num_sense = length(sense_cords(1,:));

 % initialze per step displacments
 coor_cur  = zeros(3,num_sense);
 coor_prev = coor_cur;
 %init displacement: will be (t1-t0) for all fif measurements
 meanD = zeros(length(fif)-1,1);
 fig=figure('Visible', 'off');
 %set(fig,'Visible','off')
 motion_anim=getframe;
 %posChange=[];

 %posChange = zeros(length(fif),12);
 
 % calc mean displacement (Wehner, 2008)
 for i = 1:length(fif)
     
    % if no motion change, set displacement to zero and move to next
    if(i>1 && all(fif(313:321,i) == fif(313:321,i-1)) )
        meanD(i-1) = 0;
        continue;
    end
    
    % build current head space coordinates of all unique sensor positions
    for j = 1:num_sense
       rots  = R( fif(313,i) ,fif(314,i), fif(315,i));
       trans = fif(316:318,i);
       
       %posChange(end+1,:) = [ i rots(:)' trans' ];
       %disp(posChange(end,:));

       % coordinates at current time
       coor_cur(:,j) =  rots*sense_cords(:,j) + trans;
       
    end
    
    %Visualize
    plot3(coor_cur(1,:),coor_cur(2,:),coor_cur(3,:),'k.');
    view(-90,90);
    drawnow;
    motion_anim(end+1)=getframe;
    
    
   % when there is something to compare
   if i>1
      for j = 1:num_sense
        meanD(i-1) = meanD(i-1) + norm( coor_cur(:,j) - coor_prev(:,j) );
      end
   end

   % push current to prev
   coor_prev = coor_cur;
 end

% div all sums by number of sensors
meanD = meanD./num_sense;
save('subjMotionVideo', 'motion_anim');

end

%% rotation matrix 
% Appendex D.2 (pg 77) of MaxFilter 2.1 User's Manual
function r=R(q1,q2,q3)
 r=zeros(3,3);
 q0 = sqrt( 1 - (q1^2 + q2^2 + q3^2) ); %sum q0..3 = 1

 %rot matrix
 r  = [ (q0^2 + q1^2 - q2^2 -q3^2), 2*(q1*q2 - q0*q3)         , 2*(q1*q3 + q0*q2) ; 
       2*(q1*q2 + q0*q3)          , (q0^2 + q2^2 - q1^2 -q3^2), 2*(q2*q3 + q0*q1) ; 
       2*(q1*q3 - q0*q2)          , 2*(q2*q3 + q0*q1)         , (q0^2 + q3^2 - q1^2 -q2^2)  ] ;

end
