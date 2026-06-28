export const CompareStorageHook = {
  mounted() {
    this.storageKey = "compare_colleges";
    this.syncUrlAndStorage();

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

  syncUrlAndStorage() {
    const url = new URL(window.location.href);
    const urlCollegeIds = this.parseCollegeIds(url.searchParams.get("colleges"));

    if (urlCollegeIds.length > 0) {
      this.saveCompareColleges(urlCollegeIds);
      return;
    }

    const storedCollegeIds = this.getCompareColleges();
    if (storedCollegeIds.length === 0) return;

    url.searchParams.set("colleges", storedCollegeIds.join("-"));
    window.location.assign(url.toString());
  },

  parseCollegeIds(value) {
    if (!value) return [];

    return value
      .split("-")
      .map((id) => Number.parseInt(id, 10))
      .filter((id) => Number.isInteger(id))
      .slice(0, 4);
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
      localStorage.setItem(this.storageKey, JSON.stringify(colleges.slice(0, 4)));
      document.dispatchEvent(new CustomEvent("compare-storage-updated"));
    } catch (error) {
      console.error("Error saving to localStorage:", error);
    }
  },

  triggerNavAnimation() {
    // Dispatch custom event to animate nav buttons
    document.dispatchEvent(new CustomEvent("animate-compare-nav"));
  },
};
