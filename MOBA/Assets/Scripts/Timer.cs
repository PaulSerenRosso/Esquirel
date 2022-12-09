using System.Collections;
using System.Collections.Generic;
using GameStates;
using JetBrains.Annotations;
using UnityEngine;

public class Timer
{
    private double timer;
    public event GlobalDelegates.NoParameterDelegate initiateTimerEvent;
    public event GlobalDelegates.NoParameterDelegate tickTimerEvent;
    public event GlobalDelegates.NoParameterDelegate cancelTimerEvent;
    public float time;

    public Timer(float time)
    {
        this.time = time;
    }
    public void InitiateTimer()
    {
        initiateTimerEvent?.Invoke();
        GameStateMachine.Instance.OnTick += TickTimer;
        timer = time;
    }

    public void TickTimer()
    {
        timer -= 1.0 / GameStateMachine.Instance.tickRate;
        if (timer <= 0)
        {
            tickTimerEvent?.Invoke();
        }
    }

    public void CancelTimer()
    {
        
        cancelTimerEvent?.Invoke();
    }
}