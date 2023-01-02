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
                     Debug.Log(indexOfSo);
                     Debug.Log("freeze");
                     return;
                 };
         }   

        base.SyncOnAdded(target);
    }

    public override void SyncOnRemoved(Entity target)
    {
        for (int i = 0; i < target.passiveCapacitiesList.Count; i++)
        { 
            if (target.passiveCapacitiesList[i].indexOfSo == indexOfSo)
                if (target.passiveCapacitiesList[i] != this)
                {
                    Debug.Log("freeze");
                    return;
                };
        }
       base.SyncOnRemoved(target);
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
