using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;

namespace Entities.Capacities
{
    public class ActiveAttackCapacity : ActiveCapacity
    {
        private TimerOneCount beginDamageTimer;
        protected TimerOneCount damageTimer;
        public Champion.Champion champion;
        protected ActiveCapacityAnimationLauncher activeCapacityAnimationLauncher;
        protected Quaternion rotationFx;
        public ActiveAttackCapacitySO so;
        private GameObject fxImpactObject;
        
        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
            if (onCooldown) return false;
            beginDamageTimer.InitiateTimer();
            activeCapacityAnimationLauncher.InitiateAnimationTimer();
            return true;
        }
        
        protected override void InitiateFXTimer()
        {
            base.InitiateFXTimer();
            fxObject=  PoolNetworkManager.Instance.PoolInstantiate(so.fxPrefab, champion.transform.position, rotationFx);
            ActiveAttackCapacityFX attackCapacityFX = (ActiveAttackCapacityFX)fxObject;
            attackCapacityFX.RequestInitCapacityFX(caster.entityIndex, (byte)champion.activeCapacities.IndexOf(this));
        }
        public override void InitiateCooldown()
        {
            base.InitiateCooldown();
            if(champion.activeCapacities.Contains(this))
                champion.RequestToSetOnCooldownCapacity(indexOfSOInCollection, true);
        }

        public override void EndCooldown()
        {
            champion.RequestToSetOnCooldownCapacity(indexOfSOInCollection, false);
            base.EndCooldown();
        }
        public override void CancelCapacity()
        {
            activeCapacityAnimationLauncher.CancelAnimationTimer();
            CancelFXTimer();
            beginDamageTimer.CancelTimer();
            damageTimer.CancelTimer();
        }

        
        public override void SetUpActiveCapacity(byte soIndex, Entity caster)
        {
            base.SetUpActiveCapacity(soIndex, caster);
            so = (ActiveAttackWithColliderCapacitySO)CapacitySOCollectionManager.GetActiveCapacitySOByIndex(soIndex);
            champion = (Champion.Champion)caster;
            if (PhotonNetwork.IsMasterClient)
            {
                damageTimer = new TimerOneCount(so.damageTime);
                beginDamageTimer = new TimerOneCount(so.damageBeginTime);
                beginDamageTimer.TickTimerEvent += damageTimer.InitiateTimer;
              
            }
            
            activeCapacityAnimationLauncher = new ActiveCapacityAnimationLauncher();
            activeCapacityAnimationLauncher.Setup(so.activeCapacityAnimationLauncherInfo, champion);
        }
        
    }
}
