using System;
using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using GameStates;
using Photon.Pun;
using UnityEngine;
using UnityEngine.InputSystem;
using Object = UnityEngine.Object;

namespace Entities.Capacities
{
    public class ActiveAttackCapacity : ActiveCapacity
    {
        public ActiveAttackCapacitySO so;
        public Champion.Champion champion;

        private ActiveAttackCapacityCollider _capacityColliderObject;
        private ActiveCapacityAnimationLauncher activeCapacityAnimationLauncher;
        private GameObject DamageObject;
        private TimerOneCount beginDamageTimer;
        private TimerOneCount damageTimer;

     
        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
            if (onCooldown) return false;
            activeCapacityAnimationLauncher.InitiateAnimationTimer();
            beginDamageTimer.InitiateTimer();
            return true;
        }
        
        
        void InitiateDamagePrefab()
        {
            DamageObject = PoolLocalManager.Instance.PoolInstantiate(so.damagePrefab.gameObject,
                champion.transform.position, champion.rotateParent.rotation);
            Debug.Log(DamageObject);
            var activeCapacityCollider = DamageObject.transform.GetComponent<ActiveCapacityCollider>();
            activeCapacityCollider.InitCapacityCollider(this);
        }
        
        protected virtual void CancelDamagePrefab()
        {
            if (DamageObject != null)
            {
                PoolLocalManager.Instance.EnqueuePool(so.damagePrefab.gameObject, DamageObject);
                DamageObject = null;
            }
            
        }

        public override void CancelCapacity()
        {
            beginDamageTimer.CancelTimer();
            activeCapacityAnimationLauncher.CancelAnimationTimer();
            damageTimer.CancelTimer();
            CancelFXTimer();
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

        protected override void InitiateFXTimer()
        {
            base.InitiateFXTimer();
            fxObject=  PoolNetworkManager.Instance.PoolInstantiate(so.fxPrefab, champion.transform.position, champion.rotateParent.rotation);
            ActiveAttackCapacityFX attackCapacityFX = (ActiveAttackCapacityFX)fxObject;
            attackCapacityFX.RequestInitCapacityFX(caster.entityIndex, (byte)champion.activeCapacities.IndexOf(this));
        }


        public override void SetUpActiveCapacity(byte soIndex, Entity caster)
        {
            base.SetUpActiveCapacity(soIndex, caster);
            so =(ActiveAttackCapacitySO) CapacitySOCollectionManager.GetActiveCapacitySOByIndex(soIndex);
            champion = (Champion.Champion)caster;


            if (PhotonNetwork.IsMasterClient)
            {
                damageTimer = new TimerOneCount(so.damageTime);
                beginDamageTimer = new TimerOneCount(so.damageBeginTime);
                damageTimer.initiateTimerEvent += InitiateDamagePrefab;
                beginDamageTimer.tickTimerEvent += damageTimer.InitiateTimer;
                damageTimer.cancelTimerEvent += CancelDamagePrefab;
                damageTimer.tickTimerEvent += CancelDamagePrefab;
            }

            

            activeCapacityAnimationLauncher = new ActiveCapacityAnimationLauncher();
            activeCapacityAnimationLauncher.Setup(so.activeCapacityAnimationLauncherInfo, champion);
        }
        
    }
}

