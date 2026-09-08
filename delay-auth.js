(() => {
  const subscription = firebase_auth.getAuth().authStateSubscription;
  const originalNext = subscription.next.bind(subscription);
  Object.defineProperty(subscription, "next", {value: user => {
    if (user && !user.isAnonymous) {
      setTimeout(() => originalNext(user), 5000);
    } else {
      originalNext(user);
    }
  }});
  const label = document.createElement('div');
  label.textContent = 'Issue #479 · Controlled test: auth-state notifications delayed 5 seconds';
  Object.assign(label.style, {position:'fixed',bottom:'0',left:'0',right:'0',padding:'10px',background:'#142b45',color:'white',font:'16px sans-serif',zIndex:'999999',textAlign:'center',pointerEvents:'none'});
  document.body.appendChild(label);
  document.querySelector('flt-semantics-placeholder')?.click();
  return 'Delay installed';
})()
