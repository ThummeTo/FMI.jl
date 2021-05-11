within ;
model IO

  type myEnumeration = enumeration(
      myEnumeration1 "1",
      myEnumeration2 "2");

  parameter Real p_real =                   0.0;
  parameter Integer p_integer =             0;
  parameter Boolean p_boolean =             false;
  parameter myEnumeration p_enumeration =   myEnumeration.myEnumeration1;
  parameter String p_string =               "Hello World!";

  Modelica.Blocks.Interfaces.RealInput u_real
    annotation (Placement(transformation(extent={{-130,20},{-90,60}})));
  Modelica.Blocks.Interfaces.RealOutput y_real
    annotation (Placement(transformation(extent={{90,30},{110,50}})));
  Modelica.Blocks.Interfaces.BooleanInput u_boolean
    annotation (Placement(transformation(extent={{-130,-20},{-90,20}})));
  Modelica.Blocks.Interfaces.BooleanOutput y_boolean
    annotation (Placement(transformation(extent={{90,-10},{110,10}})));
  Modelica.Blocks.Interfaces.IntegerInput u_integer
    annotation (Placement(transformation(extent={{-130,-60},{-90,-20}})));
  Modelica.Blocks.Interfaces.IntegerOutput y_integer
    annotation (Placement(transformation(extent={{90,-50},{110,-30}})));
equation
  connect(y_real, u_real)
    annotation (Line(points={{100,40},{-110,40}}, color={0,0,127}));
  connect(y_boolean, u_boolean)
    annotation (Line(points={{100,0},{-110,0}}, color={255,0,255}));
  connect(y_integer, u_integer)
    annotation (Line(points={{100,-40},{-110,-40}}, color={255,127,0}));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    uses(Modelica(version="3.2.3")));
end IO;
