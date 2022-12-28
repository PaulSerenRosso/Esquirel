using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;

namespace Entities.Capacities
{
    public class CurveMovement : MonoBehaviourPun
    {
        protected CurveMovementCapacity curveMovementCapacity;
        protected CurveMovementCapacitySO curveCapacitySo;
        private float currentTimer;
        public Transform renderer;
        private float curveTime;
        private float curveTimeRatio;
        AnimationCurve curve;
        private float curveYMaxPosition;

        private bool isEndCurve = true;
        private Vector3 startPosition;
        protected Champion.Champion champion;
        private Vector3 endPosition;
        public event GlobalDelegates.NoParameterDelegate endCurveEvent;

        public void RequestSetupRPC(byte capacityIndex, int championIndex)
        {
            photonView.RPC("LaunchSetUpRPC", RpcTarget.All, capacityIndex, championIndex);
        }

        [PunRPC]
        public void LaunchSetUpRPC(byte capacityIndex, int championIndex)
        {
            SetUp(capacityIndex, championIndex);
        }

        public virtual void SetUp(byte capacityIndex, int championIndex)
        {
            
            champion = (Champion.Champion)EntityCollectionManager.GetEntityByIndex(championIndex);
            this.curveMovementCapacity = (CurveMovementCapacity)champion.activeCapacities[capacityIndex];
            this.curveCapacitySo = curveMovementCapacity.curveMovementCapacitySo;
            curve = curveCapacitySo.curve;
            curveTime = curveCapacitySo.curveMovementTime;
            curveYMaxPosition = curveCapacitySo.curveMovementMaxYPosition;
            curveMovementCapacity.curveObject = this;

        }
        
        public void RequestStartCurveMovementRPC(Vector3 startPos, Vector3 endPos)
        {
            photonView.RPC("LaunchStartCurveMovementRPC", RpcTarget.All, startPos,  endPos);
        }

        [PunRPC]
        public void LaunchStartCurveMovementRPC(Vector3 startPos,  Vector3 endPos)
        {
            StartCurveMovementRPC(startPos, endPos);
        }

        protected virtual void StartCurveMovementRPC(Vector3 startPos, Vector3 endPos)
        {
            endPosition = endPos;
            currentTimer = 0;
            startPosition = startPos;
            transform.position = startPos;
            Debug.Log(startPos);
            isEndCurve = false;
        }

        protected virtual void OnUpdate()
        {
         
            if (currentTimer < curveTime)
                currentTimer += Time.deltaTime;
            else if(!isEndCurve)
            {
                isEndCurve = true;
                endCurveEvent?.Invoke();
            }
            else
            {
                return;
            }

   
            curveTimeRatio = currentTimer / curveTime;
            transform.position = Vector3.Lerp(startPosition, endPosition,
                curveTimeRatio);
            var transformPosition = renderer.transform.position;
            transformPosition.y = curve.Evaluate(curveTimeRatio) *
                                  curveYMaxPosition;
            renderer.transform.position = transformPosition;
        }

        void Update()
        {
            OnUpdate();
        }
    }
}