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
        speedDurationTimer.tickTimerEvent +=
            EndMove;
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
