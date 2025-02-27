using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Entities.Capacities
{
public class PrevizualisableCurveMovement : MonoBehaviour
{
    [SerializeField]
    private GameObject circleRenderer;

    [SerializeField]
    private GameObject rectRendererPivot;
    
    public void UpdatePositionAndSize(float distance, float radius)
    {
        rectRendererPivot.transform.SetGlobalScale(new Coordinate[]{new Coordinate(CoordinateType.Z, distance)});
        var transformPosition = circleRenderer.transform.localPosition;
        transformPosition.z = distance;
        circleRenderer.transform.localPosition = transformPosition;
        circleRenderer.transform.SetGlobalScale(new Vector3( radius,1,radius));
    }
}
}
