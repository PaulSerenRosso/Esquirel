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
    public class ActiveAttackCapacity<SO, COL, PREV, FX> : ActiveCapacity, IPrevisualisable
        where SO : ActiveAttackCapacitySO where COL : AttackCollider where PREV : AttackPrevizualisable where FX : AttackFX
    {
        private bool isDrawing = false;
        private PREV previsualisableObject;
        public SO so;
        public Champion.Champion champion;
        private Vector3 previsualisableObjectForward;
        private COL colliderObject;
        private bool canDraw = true;
        private ActiveCapacityAnimationLauncher activeCapacityAnimationLauncher;
        private GameObject DamageObject;
        private Timer beginDamageTimer;
        private Timer damageTimer;
     
        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
            if (onCooldown) return false;
            champion.RequestRotateMeshChampion(previsualisableObjectForward);
            activeCapacityAnimationLauncher.InitiateAnimationTimer();
            champion.SetCanMoveRPC(false);
            beginDamageTimer.InitiateTimer();
            InitiateFXTimer();
            return true;
        }

        
        void InitiateDamagePrefab()
        {
            DamageObject = PoolLocalManager.Instance.PoolInstantiate(so.damagePrefab.gameObject,
                champion.transform.position, champion.rotateParent.rotation);
            var activeCapacityCollider = DamageObject.transform.GetChild(0).GetComponent<ActiveCapacityCollider>();
            activeCapacityCollider.InitCapacityCollider(this);
        }
        
        private void CancelDamagePrefab()
        {
            if (DamageObject != null)
            {
                PoolLocalManager.Instance.EnqueuePool(so.damagePrefab.gameObject, DamageObject);
                DamageObject = null;
            }
            champion.SetCanMoveRPC(true);
            champion.RequestCurrentResetCapacityUsed();
        }

        public override void CancelCapacity()
        {
            beginDamageTimer.CancelTimer();
            activeCapacityAnimationLauncher.CancelAnimationTimer();
            damageTimer.CancelTimer();
            CancelFXTimer();
            champion.RequestCurrentResetCapacityUsed();
        }

        public override void InitiateCooldown()
        {
            base.InitiateCooldown();
            champion.RequestToSetOnCooldownCapacity(indexOfSOInCollection, true);
        }

        public override void EndCooldown()
        {
            champion.RequestToSetOnCooldownCapacity(indexOfSOInCollection, false);
            base.EndCooldown();
        }

        public void EnableDrawing()
        {
            isDrawing = true;
            InputManager.PlayerMap.MoveMouse.MousePos.performed += RotateDraw;
            previsualisableObjectForward = champion.rotateParent.transform.forward;
            previsualisableObject.gameObject.SetActive(true);
            previsualisableObject.transform.forward = previsualisableObjectForward;
        }

        void RotateDraw(InputAction.CallbackContext ctx)
        {
            previsualisableObjectForward = InputManager.inputMouseWorldPosition - champion.transform.position;
            previsualisableObjectForward.y = 0;
            previsualisableObjectForward.Normalize();
            previsualisableObject.transform.forward = previsualisableObjectForward;
        }

        public void DisableDrawing()
        {
            isDrawing = false;
            canDraw = false;
            InputManager.PlayerMap.MoveMouse.MousePos.performed -= RotateDraw;
            previsualisableObject.gameObject.SetActive(false);
        }

        public bool GetIsDrawing()
        {
            return isDrawing;
        }

        public void SetIsDrawing(bool value)
        {
            isDrawing = value;
        }

        public bool GetCanDraw()
        {
            return canDraw;
        }

        public void SetCanDraw(bool value)
        {
            canDraw = value;
        }

        public bool TryCastWithPrevisualisableData(int[] targetsEntityIndexes, Vector3[] targetPositions,
            params object[] previsualisableParameters)
        {
            previsualisableObjectForward = (Vector3)previsualisableParameters[0];
            return TryCast(targetsEntityIndexes, targetPositions);
        }

        public object[] GetPrevisualisableData()
        {
            return new[] { (object)previsualisableObjectForward };
        }

        public override void SetUpActiveCapacity(byte soIndex, Entity caster)
        {
            base.SetUpActiveCapacity(soIndex, caster);
            so = (SO)CapacitySOCollectionManager.GetActiveCapacitySOByIndex(soIndex);
            champion = (Champion.Champion)caster;


            if (PhotonNetwork.IsMasterClient)
            {
                colliderObject = PhotonNetwork.Instantiate(so.previsualisablePrefab.name, Vector3.zero,
                    Quaternion.identity).GetComponent<COL>();
                
                damageTimer = new Timer(so.damageTime);
                beginDamageTimer = new Timer(so.damageBeginTime);
                damageTimer.initiateTimerEvent += InitiateDamagePrefab;
                beginDamageTimer.tickTimerEvent += damageTimer.InitiateTimer;
                damageTimer.cancelTimerEvent += CancelDamagePrefab;
            }
            if (champion.photonView.IsMine)
            {
                previsualisableObject =
                    Object.Instantiate(so.previsualisablePrefab, champion.transform)
                        .GetComponent<PREV>();
                previsualisableObject.gameObject.SetActive(false);
                previsualisableObject.UpdatePrevisualisation(so.width, so.height);
                champion.OnSetCooldownFeedback += DisableCanDraw;
            }
            activeCapacityAnimationLauncher = new ActiveCapacityAnimationLauncher();
            activeCapacityAnimationLauncher.Setup(so.activeCapacityAnimationLauncherInfo, champion);

        }

        void DisableCanDraw(byte index, bool value)
        {
            if (index == indexOfSOInCollection)
                canDraw = true;
        }
    }
}

