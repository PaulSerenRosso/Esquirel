using System.Collections;
using System.Collections.Generic;
using Entities;
using UnityEngine;

public class TimerFxInfo 
{
    public Vector3 fxPos;
    public Quaternion fxRotation;
    public Entity fxRef;

    public TimerFxInfo(Entity fxRef) => this.fxRef = fxRef;
}
