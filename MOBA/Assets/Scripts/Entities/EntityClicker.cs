using System;
using System.Collections;
using System.Collections.Generic;
using Entities;
using UnityEngine;

namespace Entities
{
public class EntityClicker : MonoBehaviour
{
    [SerializeField] private Entity entity;
    [SerializeField] private Collider collider;
    public Entity GetEntity => entity;

    public bool EnableCollider
    {
        set
        {
            collider.enabled = value;
        }
    }
}
}
