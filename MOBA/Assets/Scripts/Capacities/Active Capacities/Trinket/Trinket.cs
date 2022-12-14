using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using Entities.FogOfWar;
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

   public void InitTrinket(ActiveTrinketCapacity activeTrinketCapacity)
   {
    if(!isSetupDespawnTimer)    
        SetupDespawnTimer();
       duration = activeTrinketCapacity.so.trinketDuration;
       ChangeTeamRPC((byte)activeTrinketCapacity.caster.team);
       despawnTimer.time = duration;
       SetViewRangeRPC(activeTrinketCapacity.so.trinketViewRadius);
       SetBaseViewRangeRPC(activeTrinketCapacity.so.trinketViewRadius);
       SetViewAngleRPC(activeTrinketCapacity.so.trinketViewAngle);
       trinketCapacity = activeTrinketCapacity;
       despawnTimer.InitiateTimer();
      
   }

   public void TickDespawnTimer()
   {
     
       PoolNetworkManager.Instance.PoolRequeue(trinketCapacity.so.trinketPrefab, this);
       
   }

   public override void OnInstantiatedFeedback()
   {
       base.OnInstantiatedFeedback();
       if(FogOfWarManager.Instance)
       FogOfWarManager.Instance.AddFOWViewable(this);
   }

   public override void OnDeainstantiatedFeedback()
   {
       base.OnDeainstantiatedFeedback();
       if(FogOfWarManager.Instance)
       FogOfWarManager.Instance.RemoveFOWViewable(this);
   }
}
}
