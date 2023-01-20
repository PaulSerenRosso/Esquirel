using System.Collections;
using System.Collections.Generic;
using Entities.FogOfWar;
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
        public TimerFX impactFxTimer;
        public TimerFxInfo impactFxTimerInfo;
        public ActiveAttackCapacitySO so;
        public TimerOneCount attackTimer;
        public float damage;
        public Vector3 directionAttack;

        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
            if (onCooldown) return false;
            beginDamageTimer.InitiateTimer();
            activeCapacityAnimationLauncher.InitiateAnimationTimer();
            InitFX(targetsEntityIndexes, targetPositions);
            attackTimer.InitiateTimer();
            return true;
        }
        
        
        protected virtual void EndAttackTimer()
        { 
            
        }

        protected virtual void InitFX(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
            fxInfo.fxPos = champion.transform.position;
            fxTimer.InitiateTimer();
            ActiveAttackCapacityFX activeAttackCapacityFX = (ActiveAttackCapacityFX)fxTimer.fxObject;
            activeAttackCapacityFX.RequestInitCapacityFX(caster.entityIndex,
                (byte)champion.activeCapacities.IndexOf(this), directionAttack);
        }

        public override void InitiateCooldown()
        {
            base.InitiateCooldown();
            if (champion.activeCapacities.Contains(this))
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
            fxTimer.CancelTimer();
            beginDamageTimer.CancelTimer();
            damageTimer.CancelTimer();
            attackTimer.CancelTimer();
        }
        
        public override void SetUpActiveCapacity(byte soIndex, Entity caster)
        {
            so = (ActiveAttackWithColliderCapacitySO)CapacitySOCollectionManager.GetActiveCapacitySOByIndex(soIndex);
            base.SetUpActiveCapacity(soIndex, caster);
            champion = (Champion.Champion)caster;
            activeCapacityAnimationLauncher = new ActiveCapacityAnimationLauncher();
            activeCapacityAnimationLauncher.Setup(so.activeCapacityAnimationLauncherInfo, champion);
            damage = so.damage;
        }

        public override void SetUpActiveCapacityForMasterClient(byte soIndex, Entity caster)
        {
            base.SetUpActiveCapacityForMasterClient(soIndex, caster);
            damageTimer = new TimerOneCount(so.damageTime);
      
            beginDamageTimer = new TimerOneCount(so.damageBeginTime);
            impactFxTimerInfo = new TimerFxInfo(so.attackCapacityImpactFx);
            attackTimer = new TimerOneCount(so.attackTime);
            impactFxTimer = new TimerFX(so.impactFxTime, impactFxTimerInfo);
            attackTimer.TickTimerEvent += EndAttackTimer;
            beginDamageTimer.TickTimerEvent += damageTimer.InitiateTimer;
        }
    }
}