within ;
model SpringTimeFrictionPendulum1D
  parameter Real fricScale = 20.0;
  parameter Modelica.SIunits.Position mass_s0 = 0.5;
  Modelica.Mechanics.Translational.Components.Fixed fixed annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-30,0})));
  Modelica.Mechanics.Translational.Components.Spring spring(c=10,
    s_rel0=1) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={0,0})));
  Modelica.Mechanics.Translational.Components.MassWithStopAndFriction mass(
    L=0,
    s(fixed=true, start=mass_s0),
    v(fixed=true, start=0),
    smax=25,
    smin=-25,
    m=1,
    F_prop=1/fricScale,
    F_Coulomb=5/fricScale,
    F_Stribeck=10/fricScale,
    fexp=2) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={40,0})));
  Modelica.Blocks.Sources.Trapezoid trapezoid(
    amplitude=5,
    rising=2,
    width=2,
    falling=2,
    period=8,
    startTime=1)
              annotation (Placement(transformation(extent={{-50,30},{-30,50}})));
  Modelica.Mechanics.Translational.Sources.Force force
    annotation (Placement(transformation(extent={{-8,30},{12,50}})));
equation
  connect(fixed.flange, spring.flange_a)
    annotation (Line(points={{-30,0},{-10,0}},
                                             color={0,127,0}));
  connect(spring.flange_b, mass.flange_a)
    annotation (Line(points={{10,0},{30,0}},  color={0,127,0}));
  connect(trapezoid.y, force.f)
    annotation (Line(points={{-29,40},{-10,40}}, color={0,0,127}));
  connect(force.flange, mass.flange_a)
    annotation (Line(points={{12,40},{20,40},{20,0},{30,0}}, color={0,127,0}));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false, extent={{-60,-60},{60,60}})),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-60,-60},{60,
            60}})),
    uses(Modelica(version="3.2.3")));
end SpringTimeFrictionPendulum1D;
