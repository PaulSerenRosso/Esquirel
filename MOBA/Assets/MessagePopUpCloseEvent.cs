using UnityEngine;

public class MessagePopUpCloseEvent : StateMachineBehaviour
{
    /// <summary>
    /// OnStateExit is called when a transition ends and the state machine finishes evaluating this state
    /// </summary>
    /// <param name="animator"></param>
    /// <param name="stateInfo"></param>
    /// <param name="layerIndex"></param>
    public override void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) => Destroy(animator.transform.parent.gameObject);
}
