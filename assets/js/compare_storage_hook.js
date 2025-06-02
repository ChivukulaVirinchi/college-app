export const CompareStorageHook = {
  mounted() {
    this.storageKey = "compare_colleges";

    // Register event handlers
    this.handleEvent("add_to_compare_storage", (payload) => {
      this.addToCompare(payload.college_id);
    });

    this.handleEvent("remove_from_compare_storage", (payload) => {
      this.removeFromCompare(payload.college_id);
    });

    this.handleEvent("update_compare_storage", (payload) => {
      this.saveCompareColleges(payload.college_ids);
    });

    this.handleEvent("trigger_compare_animation", () => {
      this.triggerNavAnimation();
    });
  },

  addToCompare(collegeId) {
    const compareColleges = this.getCompareColleges();
    if (!compareColleges.includes(collegeId)) {
      compareColleges.push(collegeId);
      this.saveCompareColleges(compareColleges);
    }
  },

  removeFromCompare(collegeId) {
    const compareColleges = this.getCompareColleges();
    const updatedColleges = compareColleges.filter((id) => id !== collegeId);
    this.saveCompareColleges(updatedColleges);
  },

  getCompareColleges() {
    try {
      return JSON.parse(localStorage.getItem(this.storageKey) || "[]");
    } catch (error) {
      return [];
    }
  },

  saveCompareColleges(colleges) {
    try {
      localStorage.setItem(this.storageKey, JSON.stringify(colleges));
      document.dispatchEvent(new CustomEvent("compare-storage-updated"));
      console.log("Saved to localStorage:", colleges); // Add this for debugging
    } catch (error) {
      console.error("Error saving to localStorage:", error);
    }
  },

  triggerNavAnimation() {
    // Dispatch custom event to animate nav buttons
    document.dispatchEvent(new CustomEvent("animate-compare-nav"));
  },
};
