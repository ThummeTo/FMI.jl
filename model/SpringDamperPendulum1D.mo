within ;
model SpringDamperPendulum1D
  Modelica.Mechanics.Translational.Components.Fixed fixed annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={0,80})));
  Modelica.Mechanics.Translational.Components.Spring spring(c=10,
    s_rel0=1) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={0,30})));
  Modelica.Mechanics.Translational.Components.Mass mass(m=1,
    s(fixed=true, start=0.5),
    v(fixed=true, start=0))                                  annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={0,-70})));
  Modelica.Mechanics.Translational.Sensors.PositionSensor positionSensor
    annotation (Placement(transformation(extent={{20,-20},{40,0}})));
  Modelica.Blocks.Interfaces.RealOutput s
    annotation (Placement(transformation(extent={{96,-20},{116,0}})));
  Modelica.Mechanics.Translational.Sensors.SpeedSensor speedSensor
    annotation (Placement(transformation(extent={{20,-50},{40,-30}})));
  Modelica.Blocks.Interfaces.RealOutput v
    annotation (Placement(transformation(extent={{96,-50},{116,-30}})));
  Modelica.Mechanics.Translational.Components.Damper damper(d=0.2) annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-40,30})));
equation
  connect(fixed.flange, spring.flange_a)
    annotation (Line(points={{0,80},{0,40}}, color={0,127,0}));
  connect(spring.flange_b, mass.flange_a) annotation (Line(points={{0,20},{0,
          -60},{1.77636e-15,-60}}, color={0,127,0}));
  connect(positionSensor.flange, mass.flange_a) annotation (Line(points={{20,-10},
          {0,-10},{0,-60},{1.77636e-15,-60}},
                                            color={0,127,0}));
  connect(positionSensor.s, s)
    annotation (Line(points={{41,-10},{106,-10}},
                                              color={0,0,127}));
  connect(speedSensor.flange, mass.flange_a) annotation (Line(points={{20,-40},
          {0,-40},{0,-60},{1.77636e-15,-60}}, color={0,127,0}));
  connect(speedSensor.v, v)
    annotation (Line(points={{41,-40},{106,-40}}, color={0,0,127}));
  connect(damper.flange_a, spring.flange_a) annotation (Line(points={{-40,40},{
          -40,60},{0,60},{0,40},{1.77636e-15,40}}, color={0,127,0}));
  connect(damper.flange_b, mass.flange_a) annotation (Line(points={{-40,20},{
          -40,0},{0,0},{0,-60},{1.77636e-15,-60}}, color={0,127,0}));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    uses(Modelica(version="3.2.3")));
end SpringDamperPendulum1D;
