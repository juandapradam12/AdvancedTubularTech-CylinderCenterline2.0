program Main;

{$APPTYPE CONSOLE}
{$R+}  // Enable range checking
{$R *.res}

uses
  SysUtils,
  Types,
  Classes,
  Matrix,
  MtxTimer,
  PCAUtils,
  ReadData,
  PrintData,
  Math,
  CircleFitUtils,
  MatrixConst,
  OptimizationUtils,
  PseudoInverseUtils,
  PseudoFitUtils,
  DimensionsIteratorUtils,
  Generics.Collections;

var
  StartTime: Int64;
  EndTime: Int64;
  DeltaTime: Double;
  DeltaTimeStr: string;

procedure InitializeFloatingPointControl;
begin
  SetExceptionMask([exOverflow, exInvalidOp, exZeroDivide]);  // Mask floating-point exceptions
end;

procedure CylinderCenterline;
var
  Points: IMatrix;
  PCAResult: TPCAResult;
  ProjectedPoints: IMatrix;
  B, D: TDoubleMatrix;
  InitialGuess: IMatrix;
  OptCircleResult: TCircleResultOpt;
  i, j: Integer;
  ParamsPseudoInverse, OptimizedParams: IMatrix;
  param_a, param_b, param_c: Double;
  param_pp_a, param_pp_b, param_pp_c: Double;
  RadiusList, CenterXList, CenterYList: TList<Double>;
  SubProjectedPoints: IMatrix;
  dim_x, dim_y: Integer;

  BestCenterX, BestCenterY, BestRadius: Double;
  MeasuredRadius: Double;

begin
  Writeln('Cylinder Centerline');
  Writeln(' ');
  Writeln('Begin Process ...');
  Writeln(' ');

  // Step 1: Read the point cloud from the file
  Points := ReadPointCloudFromFile('C:\Users\SKG Tecnología\Documents\AdvancedTubularTech-CylinderCenterline-2.0\Data\Juan Point Cloud.txt');   // Juan Point Cloud.txt -- Juan Point Cloud - Sample 3.TXT

  if Points = nil then
  begin
    Writeln('Failed to load point cloud data.');
    Exit;
  end;

  if (Points.Height <> 3) and (Points.Width = 3) then
  begin
    //Writeln('Transposing matrix to match PCA input format...');
    Points := Points.Transpose;
  end;

    // Start timer
  StartTime := MtxGetTime;

  try

    PCAResult := PerformPCA(Points, 1);

    try

      ProjectedPoints := ProjectToSelectedFeatureSpace(Points, PCAResult, 3);

      begin

        Writeln(' ');
        Writeln('Cylinder Centerline');
        Writeln(' ');
        MeasuredRadius := 12.5; // 12.5 -- 34
        FitCircleForDimensionPairs(ProjectedPoints, MeasuredRadius, BestCenterX, BestCenterY, BestRadius);
;
      end;

    finally

      ProjectedPoints := nil;
      Points := nil;   // Properly release the IMatrix reference

    end;

  except
    on E: Exception do
    begin
      Writeln('Error performing PCA: ', E.Message);
      Exit;
    end;
  end;

    // End timer
  EndTime := MtxGetTime;

  // Calculate elapsed time
  DeltaTime := (EndTime - StartTime) / mtxFreq;
  DeltaTimeStr := FloatToStr(DeltaTime);

  // Display elapsed time
  Writeln(' ');
  Writeln('Elapsed Time = ' + DeltaTimeStr + ' s');

  Writeln(' ');
  Writeln('Success!');
  Writeln(' ');
end;

begin
  try



    // Run the Cylinder Centerline Algorithm
    CylinderCenterline;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

  // Wait for user input before closing the console
  WriteLn('Press [Enter] to exit...');
  ReadLn;
end.
