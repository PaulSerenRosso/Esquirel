using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using Entities.FogOfWar;
using GameStates;
using Photon.Pun;
using UnityEngine;

namespace Entities
{
    
public class Trinket : Entity
{
   public float duration;
   private TimerOneCount despawnTimer;

   private ActiveTrinketCapacity trinketCapacity;
   private bool isSetupDespawnTimer = false;
   
   protected override void OnStart()
   {
       SetupDespawnTimer();
       base.OnStart();
   }

   private void SetupDespawnTimer()
   {
       if (!isSetupDespawnTimer)
       {
           despawnTimer = new TimerOneCount(0);
           despawnTimer.TickTimerEvent += TickDespawnTimer;
           isSetupDespawnTimer = true;
       }
   }

   public void InitTrinket(Champion.Champion champion,ActiveTrinketCapacity activeTrinketCapacity)
   {
    if(!isSetupDespawnTimer)    
        SetupDespawnTimer();
       duration = activeTrinketCapacity.so.trinketDuration;
       despawnTimer.time = duration;
       trinketCapacity = activeTrinketCapacity;
       despawnTimer.InitiateTimer();
       photonView.RPC("SyncInitTrinketRPC", RpcTarget.All, champion.entityIndex,(byte) champion.activeCapacities.IndexOf(activeTrinketCapacity));
   }

   [PunRPC]
   public void SyncInitTrinketRPC(int entityIndex, byte capacityIndex)
   {
       Champion.Champion champion =(Champion.Champion) EntityCollectionManager.GetEntityByIndex(entityIndex);
       trinketCapacity =(ActiveTrinketCapacity) champion.activeCapacities[capacityIndex];
       team = champion.team;
       if(GameStateMachine.Instance.GetPlayerTeam() == team)
           ShowElements();
       else
       {
           if(enemiesThatCanSeeMe.Count == 0)
               HideElements();
       }
       SyncSetViewRangeRPC(trinketCapacity.so.trinketViewRadius);
       SyncSetBaseViewRangeRPC(trinketCapacity.so.trinketViewRadius);
       SyncSetViewAngleRPC(trinketCapacity.so.trinketViewAngle);
       if(FogOfWarManager.Instance)
           FogOfWarManager.Instance.AddFOWViewable(this);
       transform.forward = Vector3.back;
   }

   public void TickDespawnTimer()
   {
       PoolNetworkManager.Instance.PoolRequeue(trinketCapacity.so.trinketPrefab, this);
   }
   
   public override void OnDeainstantiatedFeedback()
   {
       base.OnDeainstantiatedFeedback();
       if(FogOfWarManager.Instance)
       FogOfWarManager.Instance.RemoveFOWViewable(this);
   }
}
}
