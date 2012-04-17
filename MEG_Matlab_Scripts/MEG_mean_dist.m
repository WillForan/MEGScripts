%% calculate position of censor for each step
% in head coord (from device cords)
%
% called with one output argument, just return difference of each timepoint to the next as #####x1 vector in mm
% called with two                  return movie of motion (displayed as it's made)

function [meanD, varargout] =  MEG_mean_dist(head,fif)
 if(length(nargout)>2)
  error('MEG_mean_dist','too many outputs expected');
  return
 end

 % ensure head.info.chs.coil_trans represents postion: graph it
 %  count=0; for i=1:length(h.info.chs); if(length(h.info.chs(i).coil_trans)>3);count=count+1;  a(count,:)=h.info.chs(i).coil_trans(1:3,4);end; end; plot3(a(:,1),a(:,2),a(:,3),'k.')

 % if censor has info (>3 entries)
 % add to censor cords
 count=0; 
 for i=1:length(head.info.chs)
   trans=head.info.chs(i).coil_trans;
   if(length(trans)>3)
     count=count+1;  
     sense_cords(:,count)=trans(1:3,4)';
   end
 end

 % sense_cords like [ x1 x2 x3 x4;
 %                    y1 y2 y3 y4;
 %                    z1 z2 z3 z4 ] ;
 %


 % disp([length(a) length(unique(a,'rows'))]) % =   306   102
 % remove duplicate positions  (3 sesors at each position)
 sense_cords = unique(sense_cords','rows')';

 num_sense   = length(sense_cords(1,:));

 % initialze per step displacments
 coor_cur    = zeros(3,num_sense);
 coor_prev   = coor_cur;
 %init displacement: will be (t1-t0) for all fif measurements
 meanD = zeros(length(fif),1);

 if(nargout>1)
    figure
    varargout{1}=getframe; % first frame empty
 end

 %fig=figure('Visible', 'off');
 %set(fig,'Visible','off')
 
 %% find the start of recording
 % and give 0s while not started
 recordIdx=1;
 while( all(fif(313:321,recordIdx) == 0) )
      meanD(recordIdx) = 0;   
      recordIdx=recordIdx+1;
 end

 %% calc mean displacement (Wehner, 2008)
 for i = recordIdx:length(fif)
    % if no motion change 
    % set displacement to zero and move to next
    if( all(fif(313:321,i) == fif(313:321,i-1)) )
        meanD(i) = 0;
        continue;
    end
    
    % build current head space coordinates of all unique sensor positions
    for j = 1:num_sense
       rots  = R( fif(313,i) ,fif(314,i), fif(315,i));
       trans = fif(316:318,i);

       % coordinates at current time
       coor_cur(:,j) =  rots*sense_cords(:,j) + trans;
    end
    
    %Visualize
    if(nargout>1)
       plot3(coor_cur(1,:),coor_cur(2,:),coor_cur(3,:),'k.');
       view(-90,90);
       drawnow;
       varargout{1}(end+1)=getframe;
    end
    
    
   % when there is something to compare
   if i>recordIdx+1
      for j = 1:num_sense
        meanD(i) = meanD(i) + norm( coor_cur(:,j) - coor_prev(:,j) );
      end
   end

   % push current to prev
   coor_prev = coor_cur;
 end

 % div all sums by number of sensors
 meanD = meanD./num_sense .* 1000;
 
 % save movie for visual inspection
 %save('subjMotionVideo.mat', 'motion_anim');

end

%% rotation matrix 
% Appendex D.2 (pg 77) of MaxFilter 2.1 User's Manual
function r=R(q1, q2, q3)
 q0 = sqrt( 1 - (q1^2 + q2^2 + q3^2) ); %sum q0..3 = 1

 %rot matrix
 r  = [ (q0^2 + q1^2 - q2^2 -q3^2), 2*(q1*q2 - q0*q3)         , 2*(q1*q3 + q0*q2) ; 
       2*(q1*q2 + q0*q3)          , (q0^2 + q2^2 - q1^2 -q3^2), 2*(q2*q3 + q0*q1) ; 
       2*(q1*q3 - q0*q2)          , 2*(q2*q3 + q0*q1)         , (q0^2 + q3^2 - q1^2 -q2^2)  ] ;

end
