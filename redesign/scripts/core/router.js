/* Central SPA navigation primitive. Rendering remains owned by app.js until view extraction is complete. */
export function createRouter({state,save,render,resetViewport}){
  return {
    go(view){
      state.view=view;
      save();
      render();
      requestAnimationFrame(resetViewport);
    }
  };
}
