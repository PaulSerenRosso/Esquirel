using System.Collections;
using System.Collections.Generic;
using Entities;
using Entities.Capacities;
using Entities.Champion;
using Entities.FogOfWar;
using ExitGames.Client.Photon.StructWrapping;
using GameStates;
using UnityEngine;

public class PassiveSpeed : PassiveCapacity
{
    private PassiveSpeedSO so;
    private float currentRefSpeed;
    private IMoveable moveable;
    private Timer speedDurationTimer;
    private Champion champion;
    
    
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
        this.champion =(Champion) target;
        speedDurationTimer.InitiateTimer();
        speedDurationTimer.TickTimerEvent +=
            EndMove;
        champion.OnDie += 
            CancelPassiveWhenDie;
      
    }

    private void CancelPassiveWhenDie()
    {
        Debug.Log("je suis lancer");
        champion.RequestRemovePassiveCapacity((byte)champion.passiveCapacitiesList.IndexOf(this));
    }

    public override void SyncOnAdded(Entity target){
         base.SyncOnAdded(target);
/*         for (int i = 0; i < target.passiveCapacitiesList.Count; i++)
         { 
             if (target.passiveCapacitiesList[i].indexOfSo == indexOfSo)
                 if (target.passiveCapacitiesList[i] != this)
                 {
                     return;
                 };
         }*/
         CreateFx();
         champion = (Champion)target;
         fxObject.transform.parent = champion.rotateParent;
         var meshrenderers = fxObject.GetComponent<EntityFOWShowableLinker>().meshRenderers;
         for (int i = 0; i < meshrenderers.Length; i++)
         {
             target.meshRenderersToShow.Add(meshrenderers[i]);
             target.meshRenderersToShowAlpha.Add(1);
         }
       
        if(GameStateMachine.Instance.GetPlayerTeam() == target.team)
            target.ShowElements();
        else
        {
            //tendencer
            if(target.enemiesThatCanSeeMe.Count == 0)
                target.HideElements(); 
        }
    }

    public override void SyncOnRemoved(Entity target)
    {
        
        /*         for (int i = 0; i < target.passiveCapacitiesList.Count; i++)
         { 
             if (target.passiveCapacitiesList[i].indexOfSo == indexOfSo)
                 if (target.passiveCapacitiesList[i] != this)
                 {
                     return;
                 };
         }*/
     
       base.SyncOnRemoved(target);

       var meshrenderers = fxObject.GetComponent<EntityFOWShowableLinker>().meshRenderers;
       for (int i = 0; i < meshrenderers.Length; i++)
       {
           target.meshRenderersToShowAlpha.RemoveAt(target.meshRenderersToShow.IndexOf(meshrenderers[i]));
           target.meshRenderersToShow.Remove(meshrenderers[i]);
       }
     
        RequeueFx();
    }

    private void EndMove()
    {
        champion.RequestRemovePassiveCapacity((byte)champion.passiveCapacitiesList.IndexOf(this));
        speedDurationTimer.TickTimerEvent -= EndMove;
        champion.OnDie -= CancelPassiveWhenDie;
    }

    protected override void OnRemovedEffects(Entity target)
    {
        Debug.Log("onremovedeffect");
        moveable.RequestDecreaseCurrentMoveSpeed(so.speedFactor*currentRefSpeed);
    }
}
