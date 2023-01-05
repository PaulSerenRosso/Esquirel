using System.Collections;
using System.Collections.Generic;
using Entities;
using UnityEngine;

public class TimerFX : TimerOneCount
{
    private TimerFxInfo info;
    public Entity fxObject;

    public TimerFX(float time, TimerFxInfo info) : base(time)
    {
        this.info = info;
        InitiateTimerEvent += InitiateFxTimer;
        CancelTimerEvent +=CancelFxTimer;
        TickTimerEvent += EndFxTimer;
    }
    protected  void InitiateFxTimer()
    {
       fxObject =  PoolNetworkManager.Instance.PoolInstantiate(info.fxRef, info.fxPos, info.fxRotation);

    }

    protected  void EndFxTimer()
    {
        PoolNetworkManager.Instance.PoolRequeue(info.fxRef,fxObject);
   
    }
    protected  void CancelFxTimer()
    {
        PoolNetworkManager.Instance.PoolRequeue(info.fxRef,fxObject);
    }
    
    
}
