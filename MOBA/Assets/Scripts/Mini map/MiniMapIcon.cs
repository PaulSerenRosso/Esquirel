using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MiniMap
{
    [Serializable]
public class MiniMapIcon
{
    public MiniMapIconType type;
    public Transform worldPosition;
    public RectTransform screenPosition;
}
}
