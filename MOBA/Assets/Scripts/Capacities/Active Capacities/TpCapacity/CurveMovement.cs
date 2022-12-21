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
        [SerializeField] private MeshRenderer renderer;
        private float curveTime;
        private float curveTimeRatio;
        AnimationCurve curve;
        private float curveYMaxPosition;
       
        private Vector3 startPosition;
        protected Champion.Champion champion;
        private Vector3 endPosition;
        public event GlobalDelegates.NoParameterDelegate endCurveEvent;

        public void RequestSetupRPC(byte capacityIndex, int championIndex, Vector3 endPos)
        {
          
            photonView.RPC("LaunchSetUpRPC", RpcTarget.All, capacityIndex, championIndex, endPos);
        }

        [PunRPC]
        public void LaunchSetUpRPC(byte capacityIndex, int championIndex, Vector3 endPos)
        {
            SetUp(capacityIndex, championIndex, endPos);
        }

        protected virtual void SetUp(byte capacityIndex, int championIndex, Vector3 endPos)
        {
            champion = (Champion.Champion)EntityCollectionManager.GetEntityByIndex(championIndex);
            this.curveMovementCapacity = (CurveMovementCapacity)champion.activeCapacities[capacityIndex];
            this.curveCapacitySo = curveMovementCapacity.curveMovementCapacitySo;
            endPosition = endPos;
            currentTimer = 0;
            curve = curveCapacitySo.curve;
            curveTime = curveCapacitySo.curveMovementTime;
            curveYMaxPosition = curveCapacitySo.curveMovementMaxYPosition;
            startPosition = champion.transform.position;
        }

        protected virtual void OnUpdate()
        {
            if (currentTimer < curveTime)
                currentTimer += Time.deltaTime;
            else
            {
                endCurveEvent?.Invoke();
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