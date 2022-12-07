using System.Collections;
using System.Collections.Generic;
using Entities;
using Entities.Capacities;
using Photon.Pun;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.InputSystem;

namespace Entities.Capacities
{
    public class TpCapacity : ActiveCapacity, IPrevisualisable
    {
        private bool isDrawing = false;
        private PrevizualisableTP previsualisableTPObject;
        public TpCapacitySO tpCapacitySo;
        public Champion.Champion champion;
        private Vector3 previsualisableTPObjectForward;
        public float range;
        public Vector3 startPosition;
        public Vector3 endPosition;
        private TpObject tpObject;
        private bool canDraw = true;


        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
            if (onCooldown) return false;

            startPosition = caster.transform.position;
            champion.RequestRotateMeshChampion(previsualisableTPObjectForward);
            Vector3 candidateEndPosition = caster.transform.position + previsualisableTPObjectForward * range;
            Debug.DrawRay(caster.transform.position, previsualisableTPObjectForward * range, Color.red, 10);
            NavMeshHit navMeshHit;
            if (NavMesh.SamplePosition(candidateEndPosition, out navMeshHit, range, 1))
            {
                endPosition = navMeshHit.position;
                tpObject.RequestSetupRPC((byte) champion.activeCapacities.IndexOf(this),caster.entityIndex, endPosition);
            }
            else
            {
                Debug.LogError("don't find endPosition");
            }

            //   if(candidateEndPosition.)
            return true;
        }

        public override void CancelCapacity()
        {
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
            canDraw = false;
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
            previsualisableTPObjectForward = (Vector3) previsualisableParameters[0];
            return TryCast(targetsEntityIndexes, targetPositions);
        }

        public object[] GetPrevisualisableData()
        {
            return new[] {(object) previsualisableTPObjectForward};
        }

        public override void SetUpActiveCapacity(byte soIndex, Entity caster)
        {
            base.SetUpActiveCapacity(soIndex, caster);
            tpCapacitySo = (TpCapacitySO) CapacitySOCollectionManager.GetActiveCapacitySOByIndex(soIndex);
            champion = (Champion.Champion) caster;
            range = tpCapacitySo.referenceRange;

            if (PhotonNetwork.IsMasterClient)
            {
                tpObject = PhotonNetwork.Instantiate(tpCapacitySo.tpObjectPrefab.name, Vector3.zero,
                    Quaternion.identity).GetComponent<TpObject>();
                tpObject.RequestDeactivate();


            }
                if (caster.photonView.IsMine)
                {
                    previsualisableTPObject =
                        Object.Instantiate(tpCapacitySo.previsualisableTPPrefab, caster.transform)
                            .GetComponent<PrevizualisableTP>();
                    previsualisableTPObject.UpdatePositionAndSize(range);
                    previsualisableTPObject.gameObject.SetActive(false);
                    champion.OnSetCooldownFeedback += DisableCanDraw;
                }
        }

        void DisableCanDraw(byte index, bool value)
            {
                if (index == indexOfSOInCollection)
                    canDraw = true;
            }
        }
    }
