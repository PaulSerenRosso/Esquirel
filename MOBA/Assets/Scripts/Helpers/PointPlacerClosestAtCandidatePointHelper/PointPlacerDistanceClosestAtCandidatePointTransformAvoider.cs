using System;
using UnityEngine;

namespace PointPlacerClosestAtCandidatePointHelper
{
    public class PointPlacerDistanceClosestAtCandidatePointTransformAvoider : MonoBehaviour
    {
        public PointPlacerDistanceClosestAtCandidatePointAvoider pointAvoider;

        [SerializeField] protected float
            avoidanceDistance;

        [SerializeField] Transform avoiderTransform;

        private void OnEnable()
        {
            pointAvoider.AddToPointPlacerClosestAtCandidatePointLauncher(
                PointPlacerClosestAtCandidatePointLauncherManager.instance.GetLauncher);
        }

        private void OnDisable()
        {
            pointAvoider.RemoveToPointPlacerClosestAtCandidatePointLauncher(
                PointPlacerClosestAtCandidatePointLauncherManager.instance.GetLauncher);
        }

        protected virtual void Awake()
        {
            pointAvoider = new PointPlacerDistanceClosestAtCandidatePointAvoider();
            pointAvoider.SetAvoidanceDistance = avoidanceDistance;
        }


        private void OnDrawGizmosSelected()
        {
            Gizmos.color = Color.red;
            if (avoiderTransform != null)
                Gizmos.DrawWireSphere(avoiderTransform.position, avoidanceDistance);
        }

        private void Update()
        {
            pointAvoider.SetAvoiderPosition = avoiderTransform.position;
        }
    }
}