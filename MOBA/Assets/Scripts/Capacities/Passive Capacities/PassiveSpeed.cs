using System.Collections;
using System.Collections.Generic;
using Entities;
using Entities.Capacities;
using ExitGames.Client.Photon.StructWrapping;
using UnityEngine;

public class PassiveSpeed : PassiveCapacity
{
    private PassiveSpeedSO so;
    private float currentRefSpeed;
    private IMoveable moveable;
    private Timer speedDurationTimer;
    private Entity target;
    
    
    public override PassiveCapacitySO AssociatedPassiveCapacitySO()
    {
        return CapacitySOCollectionManager.Instance.GetPassiveCapacitySOByIndex(indexOfSo);
    }

    protected override void OnAddedEffects(Entity target)
    {
  
        so =(PassiveSpeedSO) AssociatedPassiveCapacitySO();
       moveable = target.GetComponent<IMoveable>();
       currentRefSpeed = moveable.GetReferenceMoveSpeed();
       moveable.RequestIncreaseCurrentMoveSpeed(so.speedFactor*currentRefSpeed);
        speedDurationTimer = new Timer(so.time);
        this.target = target;
        speedDurationTimer.InitiateTimer();
        speedDurationTimer.TickTimerEvent +=
            EndMove;
    }

    public override void SyncOnAdded(Entity target){
         for (int i = 0; i < target.passiveCapacitiesList.Count; i++)
         { 
             if (target.passiveCapacitiesList[i].indexOfSo == indexOfSo)
                 if (target.passiveCapacitiesList[i] != this)
                 {
                     return;
                 };
         }
         base.SyncOnAdded(target);
        target.particleSystemsToShow.Add(fxObject.GetComponent<ParticleSystem>());
        target.meshRenderersToShow.Add(fxObject.GetComponent<ParticleSystemRenderer>());
        target.meshRenderersToShowAlpha.Add(1);
    }

    public override void SyncOnRemoved(Entity target)
    {
        for (int i = 0; i < target.passiveCapacitiesList.Count; i++)
        { 
            if (target.passiveCapacitiesList[i].indexOfSo == indexOfSo)
                if (target.passiveCapacitiesList[i] != this)
                {
                    return;
                };
        }
       base.SyncOnRemoved(target);
       var particleSystem = fxObject.GetComponent<ParticleSystem>();
       var particleSystemRenderer = fxObject.GetComponent<ParticleSystemRenderer>();
       target.meshRenderersToShowAlpha.RemoveAt(target.meshRenderersToShow.IndexOf(particleSystemRenderer));
       target.particleSystemsToShow.Remove(particleSystem);
       target.meshRenderersToShow.Remove(particleSystemRenderer);
    }

    private void EndMove()
    {
        target.RequestRemovePassiveCapacity((byte)target.passiveCapacitiesList.IndexOf(this));
    }

    protected override void OnRemovedEffects(Entity target)
    {
      moveable.RequestDecreaseCurrentMoveSpeed(so.speedFactor*currentRefSpeed);
    }
}
