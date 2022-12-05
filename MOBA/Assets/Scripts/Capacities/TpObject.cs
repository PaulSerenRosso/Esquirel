using System.Collections;
using System.Collections.Generic;
using Entities;
using UnityEngine;

namespace Entities.Capacities
{
    public class TpObject : Entity
    {
        private TpCapacity tpCapacity;
        private float currentTimer;
        [SerializeField] private GameObject renderer;
        private float tpObjectCurveTime;
        private float tpObjectCurveTimeRatio;
        AnimationCurve tpObjectCurve ;
        private float tpObjectCurveYPosition;
        public void SetUp(TpCapacity tpCapacity)
        {
            this.tpCapacity = tpCapacity;
            ChangeTeamRPC((byte)tpCapacity.caster.team);
            currentTimer = 0;
            tpObjectCurve = tpCapacity.tpCapacitySo.tpObjectCurve;
            tpObjectCurveTime = tpCapacity.tpCapacitySo.tpObjectCurveTime;
            tpObjectCurveYPosition = tpCapacity.tpCapacitySo.tpObjectCurveYPosition;
        }

        protected override void OnUpdate()
        {
        
            if (currentTimer < tpObjectCurveTime)
                currentTimer += Time.deltaTime;
            else
            {
                 
                tpCapacity.champion.RequestMoveChampion(transform.position);
            }

            tpObjectCurveTimeRatio = currentTimer / tpObjectCurveTime;
            transform.position = Vector3.Lerp(tpCapacity.startPosition, tpCapacity.endPosition,
                tpObjectCurveTimeRatio);
            var transformPosition = renderer.transform.position;
            var tpObjectCurve = tpCapacity.tpCapacitySo.tpObjectCurve;
            var tpObjectCurveYPosition = tpCapacity.tpCapacitySo.tpObjectCurveYPosition;
            transformPosition.y = tpObjectCurve.Evaluate(tpObjectCurveTimeRatio) *
                                  tpObjectCurveYPosition;
            renderer.transform.position = transformPosition;
            base.OnUpdate();
        }
    }
}