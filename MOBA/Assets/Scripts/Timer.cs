using System.Collections;
using System.Collections.Generic;
using GameStates;
using JetBrains.Annotations;
using UnityEngine;

public class Timer
{
    private double timer;
    public event GlobalDelegates.NoParameterDelegate InitiateTimerEvent;
    public event GlobalDelegates.NoParameterDelegate TickTimerEvent;
    public event GlobalDelegates.NoParameterDelegate CancelTimerEvent;
    public float time;

    public Timer(float time)
    {
        this.time = time;
    }
    public void InitiateTimer()
    {
        InitiateTimerEvent?.Invoke();
        GameStateMachine.Instance.OnTick += TickTimer;
        timer = time;
    }

    public void TickTimer()
    {
        timer -= 1.0 / GameStateMachine.Instance.tickRate;
        if (timer <= 0)
        {
            TickTimerEvent?.Invoke();
        }
    }

    public void CancelTimer()
    {
        
        CancelTimerEvent?.Invoke();
    }
}