using System.Collections;
using System.Collections.Generic;
using GameStates;
using UnityEngine;

public class TimerOneCount : Timer
{
    public TimerOneCount(float time) : base(time)
    {
        tickTimerEvent += delegate {   GameStateMachine.Instance.OnTick -= TickTimer; }; 
    }
}
