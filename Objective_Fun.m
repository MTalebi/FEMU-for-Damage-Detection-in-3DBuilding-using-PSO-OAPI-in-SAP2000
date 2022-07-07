function [Cost]=Objective_Fun(x,Autoselect_List_Names,Output_Sensor_Joints,Sensor_Points,BeamsRows,ColsRows,BRsRows,Acc_Measured_Time,FrameObj,Analyze,AnalysisResults,SapModel)
    SapModel.SetModelIsLocked(false);
    StiffModifBeams=x(1:size(BeamsRows,1));
    StiffModifCols=x(size(BeamsRows,1)+1:size(BeamsRows,1)+size(ColsRows,1)*2);
    StiffModifBrs=x(size(BeamsRows,1)+size(ColsRows,1)*2+1:size(BeamsRows,1)+size(ColsRows,1)*2+size(BRsRows,1));
    
    for i=1:size(BeamsRows,1)
        FrameSectionGroup_Name=Autoselect_List_Names{BeamsRows(i),1};
        
        All_Modif_Frame=ones(1,8);
        All_Modif_Frame(1,6)=StiffModifBeams(1,i); 
        
        FrameObj.SetModifiers(FrameSectionGroup_Name,All_Modif_Frame,SAP2000v1.eItemType.Group);
    end

    for i=1:size(ColsRows,1)
        FrameSectionGroup_Name=Autoselect_List_Names{ColsRows(i),1};
        
        All_Modif_Frame=ones(1,8);
        
        All_Modif_Frame(1,5)=StiffModifCols(1,2*i-1); 
        All_Modif_Frame(1,6)=StiffModifCols(1,2*i); 
        
        FrameObj.SetModifiers(FrameSectionGroup_Name,All_Modif_Frame,SAP2000v1.eItemType.Group);
    end
    

    if ~isempty(BRsRows)
        for i=1:size(BRsRows,1)
            FrameSectionGroup_Name=Autoselect_List_Names{BRsRows(i),1};

            All_Modif_Frame=ones(1,8);
            All_Modif_Frame(1,1)=StiffModifBrs(1,i); 

            FrameObj.SetModifiers(FrameSectionGroup_Name,All_Modif_Frame,SAP2000v1.eItemType.Group);
        end    
    end
    
    Analyze.RunAnalysis;
    
    [~,~,~,Point_Names,~,~,Time_Result,ACC_X,ACC_Y,~,~,~,~]=AnalysisResults.JointAcc(Output_Sensor_Joints,SAP2000v1.eItemTypeElm.GroupElm,0,cellstr(''),cellstr(''),cellstr(''),cellstr(''),0,0,0,0,0,0,0);
    Point_Names=cell(Point_Names)'; Time_Result=double(Time_Result)';ACC_X=double(ACC_X)';ACC_Y=double(ACC_Y)';
    for i=1:size(Sensor_Points,1)
        indix_Result_Point=find(strcmp(Point_Names(:,1),Sensor_Points(i,1)));
        Acc_Model_Time.(['Point',char(Sensor_Points(i,1))])=[Time_Result(indix_Result_Point,1),ACC_X(indix_Result_Point,1),ACC_Y(indix_Result_Point,1)];
    end
    %cost calc
    Cost=0;
    for i=1:size(Sensor_Points,1)
        acc_model=Acc_Model_Time.(['Point',char(Sensor_Points(i,1))]);
        acc_measured=Acc_Measured_Time.(['Point',char(Sensor_Points(i,1))]);
        
        acc_measured_downsampled(:,1)=interp1(acc_measured(:,1),acc_measured(:,2),acc_model(:,1)); %Analysis time steps could be arbitrary
        acc_measured_downsampled(:,2)=interp1(acc_measured(:,1),acc_measured(:,3),acc_model(:,1)); %Analysis time steps could be arbitrary
        
        Cost=Cost+norm(acc_measured_downsampled(:,1)-acc_model(:,2))+norm(acc_measured_downsampled(:,2)-acc_model(:,3));  
        
        
    end
    Cost=Cost/size(Sensor_Points,1)/size(acc_measured_downsampled,1)/size(acc_measured_downsampled,2)*100;
    
end