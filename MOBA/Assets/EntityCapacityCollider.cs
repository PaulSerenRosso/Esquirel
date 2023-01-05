using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Entities
{
public class EntityCapacityCollider : MonoBehaviour
{

    [SerializeField] private Entity entity;
    [SerializeField] private Collider collider;

    public Collider GetCollider => collider;
    public void EnableEntityCollider()
    {
        collider.enabled = true;
    }

    public void DisableEntityCollider()
    {
        collider.enabled = false;
    }

    public Entity GetEntity => entity;
}
    
}
