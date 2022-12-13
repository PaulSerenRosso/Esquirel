using System;
using System.Collections;
using System.Collections.Generic;
using Entities.Champion;
using GameStates;
using UnityEngine;

namespace Entities.Capacities
{
[Serializable]
public class ActiveCapacityAnimationLauncher
{
    private Champion.Champion caster;
    private double animationTime;
    private double animationTimer;
    private string animatorParameterName;

    public virtual void Setup(ActiveCapacityAnimationLauncherInfo activeCapacityAnimationLauncherInfo, Champion.Champion champion)
    {
        this.animationTime = activeCapacityAnimationLauncherInfo.animationTime;
        this.caster = champion;
        animatorParameterName = activeCapacityAnimationLauncherInfo.animatorParameterName;
    }
    
    public virtual void InitiateAnimationTimer()
    {
        animationTimer = animationTime;
        caster.RequestChangeBoolParameterAnimator(animatorParameterName, true);
        GameStateMachine.Instance.OnTick += TickAnimationTimer;
    }
        
    public virtual  void CancelAnimationTimer()
    {
        caster.RequestChangeBoolParameterAnimator(animatorParameterName, false);
        GameStateMachine.Instance.OnTick -= TickAnimationTimer;
    }
        
    public virtual  void TickAnimationTimer()
    {
        animationTimer -= 1.0 / GameStateMachine.Instance.tickRate;

        if (animationTimer <= 0)
        {
            CancelAnimationTimer();
        }
    }
}
}
