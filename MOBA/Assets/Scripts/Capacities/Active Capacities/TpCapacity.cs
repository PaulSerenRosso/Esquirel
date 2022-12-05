using System.Collections;
using System.Collections.Generic;
using Entities;
using Entities.Capacities;
using Photon.Pun;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Entities.Capacities
{
    public class TpCapacity : ActiveCapacity, IPrevisualisable
    {
        private bool isDrawing = false;
        private PrevizualisableTP previsualisableTPObject;
        private TpCapacitySO tpCapacitySo;
        private Champion.Champion champion;
        private Vector3 previsualisableTPObjectForward;
        public float range;
        private Vector2 startPosition;
        private Vector2 endPosition;
        private TpObject tpObject;

        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
            if (onCooldown) return false;
            InitiateCooldown();
            startPosition = caster.transform.position;
            Vector3 candidateEndPosition = caster.transform.position+previsualisableTPObjectForward * range; 
         //   if(candidateEndPosition.)
            return true;
        }

        public override void CancelCapacity()
        {
        }

        protected override void InitiateCooldown()
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
            Debug.Log("je suis joue là");
            InputManager.PlayerMap.MoveMouse.MousePos.performed += RotateDraw;
            previsualisableTPObjectForward = caster.transform.forward;
            previsualisableTPObject.gameObject.SetActive(true);
        }

        void RotateDraw(InputAction.CallbackContext ctx)
        {
            previsualisableTPObjectForward = InputManager.inputMouseWorldPosition - caster.transform.position;
            previsualisableTPObjectForward.y = 0;
            previsualisableTPObjectForward.Normalize();
            previsualisableTPObject.transform.forward = previsualisableTPObjectForward;
        }

        public void DisableDrawing()
        {
            isDrawing = false;
            Debug.Log("je suis joue là aussi");
            InputManager.PlayerMap.MoveMouse.MousePos.performed -= RotateDraw;
            previsualisableTPObject.gameObject.SetActive(false);
        }

        public bool GetIsDrawing()
        {
            return isDrawing;
        }

        public void SetIsDrawing(bool value)
        {
            isDrawing = value;
        }

        public override void SetUpActiveCapacity(byte soIndex, Entity caster)
        {
            base.SetUpActiveCapacity(soIndex, caster);
            tpCapacitySo = (TpCapacitySO)CapacitySOCollectionManager.GetActiveCapacitySOByIndex(soIndex);
            champion = (Champion.Champion)caster;
            range = tpCapacitySo.referenceRange;

            if (PhotonNetwork.IsMasterClient)
            {
                tpObject = PhotonNetwork.Instantiate(tpCapacitySo.tpObjectPrefab.name, Vector3.zero,
                    Quaternion.identity).GetComponent<TpObject>();
                tpObject.gameObject.SetActive(false);
            }

            if (caster.photonView.IsMine)
            {
                previsualisableTPObject =
                    Object.Instantiate(tpCapacitySo.previsualisableTPPrefab, caster.transform)
                        .GetComponent<PrevizualisableTP>();
                previsualisableTPObject.UpdatePositionAndSize(range);
                previsualisableTPObject.gameObject.SetActive(false);
            }
        }
    }
}