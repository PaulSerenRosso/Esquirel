using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Entities.Capacities
{
    public class CurveMovementWithPrevisualisableCapacity : CurveMovementCapacity, IPrevisualisable
    {
        private bool isDrawing = false;
        protected PrevizualisableCurveMovement _previsualisableCurveMovementObject;
        private Vector3 previsualisableCurveMovementObjectForward;
        private bool canDraw = true;


        private bool skipDrawing = false;

        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {

            if (champion.CheckCurrentCapacityForCastableCapacity())
            {
            if (base.TryCast(targetsEntityIndexes, targetPositions))
            {
                activeCapacityAnimationLauncher.InitiateAnimationTimer();
                startPosition = caster.transform.position;
                activeCapacityAnimationLauncher.InitiateAnimationTimer();
                endPosition = caster.transform.position + previsualisableCurveMovementObjectForward * range;
                SearchEndPositionAvailable();
                return true;
            }
            }

            return false;
        }

        public override void SyncCapacity(int[] targetsEntityIndexes, Vector3[] targetPositions, params object[] customParameters)
        {
            base.SyncCapacity(targetsEntityIndexes, targetPositions, customParameters);
            champion.RotateMeshChampionRPC(previsualisableCurveMovementObjectForward);
            
        }

        public void EnableDrawing()
        {
            isDrawing = true;
            InputManager.PlayerMap.MoveMouse.MousePos.performed += RotateDraw;
            previsualisableCurveMovementObjectForward = InputManager.inputMouseWorldPosition - champion.transform.position;
            previsualisableCurveMovementObjectForward.y = 0;
            previsualisableCurveMovementObjectForward.Normalize();
            _previsualisableCurveMovementObject.gameObject.SetActive(true);
            _previsualisableCurveMovementObject.transform.forward = previsualisableCurveMovementObjectForward;
        }

        void RotateDraw(InputAction.CallbackContext ctx)
        {
            previsualisableCurveMovementObjectForward =
                InputManager.inputMouseWorldPosition - caster.transform.position;
            previsualisableCurveMovementObjectForward.y = 0;
            previsualisableCurveMovementObjectForward.Normalize();
            _previsualisableCurveMovementObject.transform.forward = previsualisableCurveMovementObjectForward;
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
        public void DisableDrawing()
        {
            isDrawing = false;
            InputManager.PlayerMap.MoveMouse.MousePos.performed -= RotateDraw;
            _previsualisableCurveMovementObject.gameObject.SetActive(false);
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
            if (!champion.CheckCurrentCapacityForCastableCapacity()) return false;
            return canDraw;
        }

        public void SetCanDraw(bool value)
        {
            canDraw = value;
        }

        public bool TryCastWithPrevisualisableData(int[] targetsEntityIndexes, Vector3[] targetPositions,
            params object[] previsualisableParameters)
        {
            if(previsualisableParameters != null)
            if(previsualisableParameters.Length != 0)
            previsualisableCurveMovementObjectForward = (Vector3)previsualisableParameters[0];
            return TryCast(targetsEntityIndexes, targetPositions);
        }

        public object[] GetPrevisualisableData()
        {
            return new[] { (object)previsualisableCurveMovementObjectForward };
        }

        public bool GetCanSkipDrawing()
        {
            return skipDrawing; 
        }

        public void SetCanSkipDrawing(bool value)
        {
            skipDrawing = value;
        }

        void DisableCanDraw(byte index, bool value)
        {
            if (index == indexOfSOInCollection)
                canDraw = true;
        }

        public override void SetUpActiveCapacity(byte soIndex, Entity caster)
        {
            base.SetUpActiveCapacity(soIndex, caster);
            champion = (Champion.Champion)caster;
            activeCapacityAnimationLauncher = new ActiveCapacityAnimationLauncher();
            activeCapacityAnimationLauncher.Setup(curveMovementCapacitySo.activeCapacityAnimationLauncherInfo,
                champion);
            if (caster.photonView.IsMine)
            {
                CurveMovementWithPrevisualisableCapacitySO curveMovementWithPrevisualisableCapacitySo =
                    (CurveMovementWithPrevisualisableCapacitySO)curveMovementCapacitySo;
                _previsualisableCurveMovementObject =
                    Object.Instantiate(curveMovementWithPrevisualisableCapacitySo.previsualisableCurveMovementPrefab, caster.transform)
                        .GetComponent<PrevizualisableCurveMovement>();
              
                champion.OnSetCooldownFeedback += DisableCanDraw;
            }
        }
    }
}