import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
    stages: [
        { duration: "1m" , target: 100},
        { duration: "3m", target: 100},
        { duration: "1m", target: 0 },
    ],
};

export default function () {
    http.get('http://k8s-default-phoenixa-6759e117e3-1231671589.ap-south-1.elb.amazonaws.com');
    sleep(1);
}