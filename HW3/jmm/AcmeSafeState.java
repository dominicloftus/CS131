import java.util.concurrent.atomic.AtomicLongArray;

class AcmeSafeState implements State {
    private AtomicLongArray value;

    AcmeSafeState(int length) { 
        value = new AtomicLongArray(length);
    }

    public int size() { return value.length(); }

    public long[] current() { 
        long[] ret = new long[value.length()];
        for(int i = 0; i < ret.length; i++)
            ret[i] = value.get(i);
        return ret;
    }

    public void swap(int i, int j) {
	    value.addAndGet(i, -1);
	    value.addAndGet(j, 1);
    }
}
